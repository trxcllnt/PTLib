package com.pt.components.controls.itemRenderers
{
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.controls.grid.DataGridSegmentGroup;
    import com.pt.components.controls.itemRenderers.layout.SegmentRendererLayout;
    import com.pt.utils.MultiTypeObjectPool;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    
    import mx.containers.BoxDirection;
    import mx.core.ClassFactory;
    import mx.core.IDataRenderer;
    import mx.core.IFactory;
    import mx.core.UIComponent;
    
    public class DataGridListSegmentRenderer extends UIComponent implements IDataRenderer
    {
        public function DataGridListSegmentRenderer():void
        {
            layout.target = this;
        }
        
        protected var layout:SegmentRendererLayout = new SegmentRendererLayout();
        
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
            if(value === _data)
                return;
            
            _data = value;
            
            if(segments.length && numChildren)
                commitSegmentData(segments, this);
            
            invalidateSize();
            invalidateDisplayList();
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
            
            if(!value)
                return;
            
            _segments = value;
            
            layout.segments = segments;
            
            createSegmentRenderers(segments, this);
            
            if(_segments.length)
            {
                segmentsChanged = true;
                
                if(data)
                    commitSegmentData(segments, this);
                
                invalidateSize();
                invalidateDisplayList();
            }
        }
        
        protected function createSegmentRenderers(children:Vector.<DataGridSegment>, rendererParent:DisplayObjectContainer):void
        {
            var n:int = children.length;
            var segment:DataGridSegment;
            
            for(var i:int = 0; i < n; ++i)
            {
                createSegmentRenderer(children[i], i, rendererParent);
            }
            while(rendererParent.numChildren > n)
            {
                pool.checkIn(rendererParent.removeChildAt(rendererParent.numChildren - 1));
            }
        }
        
        protected function createSegmentRenderer(segment:DataGridSegment, index:int, rendererParent:DisplayObjectContainer):DisplayObject
        {
            var renderer:DisplayObject;
            var factory:IFactory = segment.renderer;
            var type:Class;
            
            if(factory is ClassFactory)
                type = ClassFactory(factory).generator;
            else
                type = factory.newInstance()['constructor'];
            
            if(pool.has(type) == false)
                pool.add(type, factory);
            
            renderer = index < rendererParent.numChildren ?
                rendererParent.getChildAt(index) :
                DisplayObject(pool.checkOut(type));
            
            if(!(renderer is type))
            {
                if(rendererParent.contains(renderer))
                {
                    pool.checkIn(rendererParent.removeChild(renderer));
                }
                renderer = DisplayObject(pool.checkOut(type));
            }
            
            if(factory is ClassFactory)
            {
                var props:Object = ClassFactory(factory).properties;
                for(var prop:String in props)
                    renderer[prop] = props[prop];
            }
            
            if(!rendererParent.contains(renderer))
                rendererParent.addChildAt(renderer, index);
            
            if(!isNaN(segment.size))
            {
                renderer[isV() ? 'height' : 'width'] = segment.size;
            }
            
            return renderer;
        }
        
        protected function commitSegmentData(children:Vector.<DataGridSegment>, parentRenderer:DisplayObjectContainer):void
        {
            var n:int = children.length;
            
            for(var i:int = 0; i < n; i++)
            {
                commitRendererData(parentRenderer.getChildAt(i), children[i]);
            }
        }
        
        protected function commitRendererData(renderer:DisplayObject, segment:DataGridSegment):void
        {
            if(segment.rendererField in renderer)
                renderer[segment.rendererField] = segment.applyData(data);
            else if('data' in renderer)
                renderer['data'] = segment.applyData(data);
            
            if(segment is DataGridSegmentGroup)
            {
                if('segments' in renderer)
                    renderer['segments'] = DataGridSegmentGroup(segment).children;
            }
        }
        
        override protected function measure():void
        {
            super.measure();
            
            if(segmentsChanged)
                layout.measure();
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            layout.updateDisplayList(w, h);
            
            segmentsChanged = false;
        }
    }
}