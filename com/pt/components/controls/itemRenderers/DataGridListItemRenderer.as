package com.pt.components.controls.itemRenderers
{
    import com.pt.components.containers.VirtualContainer;
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.containers.layout.HLayout;
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.utils.MultiTypeObjectPool;
    import com.pt.virtual.Virtual;
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.containers.BoxDirection;
    import mx.core.ClassFactory;
    import mx.core.IDataRenderer;
    import mx.core.IFactory;
    import mx.core.IUIComponent;
    import mx.core.ScrollPolicy;
    import mx.core.UIComponent;
    
    public class DataGridListItemRenderer extends UIComponent implements IDataRenderer
    {
        public function DataGridListItemRenderer()
        {
            super();
        }
        
        protected static var pool:MultiTypeObjectPool = new MultiTypeObjectPool();
        
        public var index:int = 0;
        
        private var _direction:String = BoxDirection.HORIZONTAL;
        
        [Inspectable(category="General", enumeration="vertical,horizontal")]
        
        public function get direction():String
        {
            return _direction;
        }
        
        public function set direction(value:String):void
        {
            if(value === _direction)
                return;
            
            _direction = value;
            
            segmentsChanged = true;
            invalidateSize();
            invalidateDisplayList();
        }
        
        protected function isV():Boolean
        {
            return direction == BoxDirection.VERTICAL;
        }
        
        private var _data:Object;
        
        public function get data():Object
        {
            return _data;
        }
        
        public function set data(value:Object):void
        {
            _data = value;
            
            if(!data)
                return;
            
            setData(data);
            invalidateDisplayList();
        }
        
        protected function setData(data:Object):void
        {
            var segment:DataGridSegment;
            var renderer:DisplayObject;
            var n:int = segments.length;
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                renderer = getChildAt(i);
                
                if(segment.rendererField in renderer)
                {
                    renderer[segment.rendererField] = segment.dataFunction(data);
                }
                else if('data' in renderer)
                {
                    renderer['data'] = segment.dataFunction(data);
                }
            }
        }
        
        private var segmentsChanged:Boolean = false;
        protected var _segments:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
        
        public function get segments():Vector.<DataGridSegment>
        {
            return _segments;
        }
        
        public function set segments(value:Vector.<DataGridSegment>):void
        {
            if(value === _segments)
                return;
            
            _segments = value;
            segmentsChanged = true;
            
            createSegmentRenderers();
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(segmentsChanged)
            {
                data = data;
            }
        }
        
        protected function createSegmentRenderers():void
        {
            var n:int = segments.length;
            var segment:DataGridSegment;
            var renderer:DisplayObject;
            var factory:IFactory;
            var type:Class;
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                
                factory = segment.renderer;
                
                if(factory is ClassFactory)
                    type = ClassFactory(factory).generator;
                else
                    type = factory.newInstance()['constructor'];
                
                if(!pool.has(type))
                    pool.add(type, factory);
                
                renderer = i < numChildren ?
                    getChildAt(i) :
                    DisplayObject(pool.checkOut(type));
                
                if(!(renderer is type))
                {
                    if(contains(renderer))
                    {
                        pool.checkIn(removeChild(renderer));
                    }
                    renderer = DisplayObject(pool.checkOut(type));
                }
                
                if(!contains(renderer))
                    addChildAt(renderer, i);
                
                if(!isNaN(segment.size))
                {
                    renderer[isV() ? 'height' : 'width'] = segment.size;
                }
            }
            
            while(numChildren > n)
            {
                pool.checkIn(removeChildAt(numChildren - 1));
            }
        }
        
        override protected function measure():void
        {
            if(!isV() && isNaN(explicitHeight))
                measuredHeight = 30;
            else if(isV() && isNaN(explicitWidth))
                measuredWidth = 30;
            
            if(!segmentsChanged)
                return;
            
            var segment:DataGridSegment;
            var n:int = segments.length;
            var renderer:DisplayObject;
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                renderer = getChildAt(i);
                segment.measuredSize = Math.max(renderer is IUIComponent ?
                                                IUIComponent(renderer)[isV() ? 'getExplicitOrMeasuredHeight' : 'getExplicitOrMeasuredWidth']() :
                                                renderer[isV() ? 'height' : 'width'],
                                                segment.measuredSize);
            }
        }
        
        private var bgRect:Rectangle = new Rectangle();
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            if(segmentsChanged)
            {
                var segment:DataGridSegment;
                var segmentSize:Number;
                var n:int = segments.length;
                var renderer:DisplayObject;
                var aggregate:Number = 0;
                
                var bgSize:Rectangle = new Rectangle();
                
                var pos:Point = new Point();
                var size:Point = new Point();
                var sizeProp:String = isV() ? 'height' : 'width';
                var offProp:String = isV() ? 'width' : 'height';
                
                for(var i:int = 0; i < n; i++)
                {
                    segment = segments[i];
                    
                    renderer = getChildAt(i);
                    
                    segmentSize = segment.size || segment.measuredSize;
                    
                    if(i == 0)
                    {
                        bgRect.x = segment.position.x;
                        bgRect.y = segment.position.y;
                        bgRect.width = w + (isV() ? segmentSize : w);
                        bgRect.height = h + (isV() ? h : segmentSize);
                    }
                    
                    pos.x = segment.position.x;
                    pos.y = segment.position.y;
                    
                    if(isV())
                    {
                        size.x = w;
                        size.y = segmentSize;
                    }
                    else
                    {
                        size.x = segmentSize;
                        size.y = h;
                    }
                    
                    if(renderer is IUIComponent)
                    {
                        
                        IUIComponent(renderer).setActualSize(Math.min(size.x, IUIComponent(renderer).getExplicitOrMeasuredWidth()),
                                                             Math.min(size.y, IUIComponent(renderer).getExplicitOrMeasuredHeight()));
                        IUIComponent(renderer).move(pos.x + Math.max((size.x - renderer.width) / 2, 0),
                                                    pos.y + Math.max((size.y - renderer.height) / 2, 0));
                    }
                    else
                    {
                        renderer.width = size.x;
                        renderer.height = size.y;
                        renderer.x = pos.x + Math.max((size.x - renderer.width) / 2, 0);
                        renderer.y = pos.y + Math.max((size.y - renderer.height) / 2, 0);
                    }
                }
            }
            
            var g:Graphics = graphics;
            g.clear();
            g.beginFill(index % 2 == 0 ? 0xFFFFFF : 0xDDEEFF, 1);
            g.drawRect(bgRect.x, bgRect.y, bgRect.width, bgRect.height);
            
            segmentsChanged = false;
        }
    }
}