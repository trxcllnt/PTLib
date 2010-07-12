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
            
            createColumnRenderers();
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
        
        protected function createColumnRenderers():void
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
                //  Try to get the renderer's type for object pooling without instantiating it.
                //  If we have to instantiate it, we've all but lost the benefit of object pooling.
                if(factory is ClassFactory)
                    type = ClassFactory(factory).generator;
                else
                    type = factory.newInstance()['constructor'];
                
                if(!pool.has(type))
                    pool.add(type);
                
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
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            if(!segmentsChanged)
                return;
            
            var segment:DataGridSegment;
            var segmentSize:Number;
            var n:int = segments.length;
            var renderer:DisplayObject;
            var aggregate:Number = 0;
            
            var g:Graphics = graphics;
            g.clear();
            g.lineStyle(1, 0xCCCCCC);
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                renderer = getChildAt(i);
                
                if(renderer is IUIComponent)
                {
                    segmentSize = segment.size || segment.measuredSize;
                    IUIComponent(renderer).setActualSize(isV() ? w : segmentSize, isV() ? h : segmentSize);
                    IUIComponent(renderer).move(segment.position.x, segment.position.x);
                }
                else
                {
                    renderer[isV() ? 'height' : 'width'] = segment.size;
                    renderer[isV() ? 'width' : 'height'] = isV() ? w : h;
                    renderer.x = segment.position.x;
                    renderer.y = segment.position.y;
                }
                
                if(isV())
                {
                    g.moveTo(w, renderer.y);
                    g.lineTo(w, renderer.y + renderer.height);
                    g.moveTo(0, renderer.y);
                    g.lineTo(w, renderer.y);
                }
                else
                {
                    g.moveTo(renderer.x, h);
                    g.lineTo(renderer.x + renderer.width, h);
                    g.moveTo(renderer.x, 0);
                    g.lineTo(renderer.x, h);
                }
            }
            
            segmentsChanged = false;
        }
    }
}