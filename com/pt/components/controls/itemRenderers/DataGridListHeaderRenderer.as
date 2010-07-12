package com.pt.components.controls.itemRenderers
{
    import com.pt.components.controls.grid.DataGridSegment;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    
    import mx.core.ClassFactory;
    import mx.core.IFactory;
    
    public class DataGridListHeaderRenderer extends DataGridListItemRenderer
    {
        public function DataGridListHeaderRenderer()
        {
            super();
        }
        
        private var _computedSegments:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
        
        public function get computedSegments():Vector.<DataGridSegment>
        {
            return _computedSegments;
        }
        
        override public function set segments(value:Vector.<DataGridSegment>):void
        {
            if(value != segments)
                _computedSegments = new Vector.<DataGridSegment>();
            
            super.segments = value;
        }
        
        override protected function setData(data:Object):void
        {
            var segment:DataGridSegment;
            var renderer:DisplayObject;
            var n:int = segments.length;
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                renderer = getChildAt(i);
                
                processSegment(segment, renderer);
            }
        }
        
        private function processSegment(segment:DataGridSegment, renderer:DisplayObject):void
        {
            if(segment.headerField && segment.headerField in renderer)
            {
                renderer[segment.headerField] = segment.title;
            }
            else if('data' in renderer)
            {
                renderer['data'] = segment.title;
            }
            
            var n:int = segment.children.length;
            if(n && renderer is DisplayObjectContainer)
            {
                for(var i:int = 0; i < n; i++)
                {
                    processSegment(segment.children[i], DisplayObjectContainer(renderer).getChildAt(i));
                }
            }
        }
        
        override protected function createSegmentRenderers():void
        {
            var n:int = segments.length;
            var segment:DataGridSegment;
            
            for(var i:int = 0; i < n; ++i)
            {
                createSegmentRenderer(segments[i], i, this);
            }
            while(numChildren > n)
            {
                pool.checkIn(removeChildAt(numChildren - 1));
            }
        }
        
        private function createSegmentRenderer(segment:DataGridSegment, index:int, p:DisplayObjectContainer):void
        {
            _computedSegments.push(segment);
            
            var renderer:DisplayObject;
            var factory:IFactory = segment.header;
            var type:Class;
            
            if(factory is ClassFactory)
                type = ClassFactory(factory).generator;
            else
                type = factory.newInstance()['constructor'];
            
            if(!pool.has(type))
                pool.add(type, factory);
            
            renderer = index < p.numChildren ?
                p.getChildAt(index) :
                DisplayObject(pool.checkOut(type));
            
            if(!(renderer is type))
            {
                if(contains(renderer))
                {
                    pool.checkIn(p.removeChild(renderer));
                }
                renderer = DisplayObject(pool.checkOut(type));
            }
            
            if(p.contains(renderer) == false)
                p.addChildAt(renderer, index);
            
            if(!isNaN(segment.size))
            {
                renderer[isV() ? 'height' : 'width'] = segment.size;
            }
            
            var n:int = segment.children.length;
            if(n && renderer is DisplayObjectContainer)
            {
                p = DisplayObjectContainer(renderer);
                
                for(var i:int = 0; i < n; ++i)
                {
                    createSegmentRenderer(segment.children[i], i, p);
                }
                while(p.numChildren > n)
                {
                    pool.checkIn(p.removeChildAt(p.numChildren - 1));
                }
            }
        }
    }
}