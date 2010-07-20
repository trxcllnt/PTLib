package com.pt.components.controls.itemRenderers.grid
{
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.controls.grid.DataGridSegmentGroup;
    import com.pt.components.controls.grid.events.HeaderSortEvent;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    
    import mx.core.ClassFactory;
    import mx.core.IFactory;
    
    public class DataGridListHeaderRenderer extends DataGridListSegmentRenderer
    {
      public function DataGridListHeaderRenderer()
      {
        addEventListener(HeaderSortEvent.SORT, onSortHeader);
      }
      
      private function onSortHeader(event:HeaderSortEvent):void
      {
        disableRenderers(this, DisplayObject(event.target));
      }
      
      private function disableRenderers(parent:DisplayObjectContainer, except:DisplayObject):void
      {
        var n:int = parent.numChildren;
        var child:DisplayObject;
        
        for(var i:int = 0; i < n; i++)
        {
          child = parent.getChildAt(i);
          if('selected' in child && child != except)
            child['selected'] = false;
          
          if(child is DisplayObjectContainer)
            disableRenderers(DisplayObjectContainer(child), except);
        }
      }
      
        override public function set segments(value:Vector.<DataGridSegment>):void
        {
            var hasGroups:Boolean = false
            if(value !== _segments)
            {
                var i:int = -1;
                while(++i < numChildren && !hasGroups)
                    hasGroups = (getChildAt(i) is SegmentHeaderGroupRenderer);
            }
            if(hasGroups)
                while(numChildren)
                    removeChildAt(0);
            
            super.segments = value;
        }
        
        override protected function commitRendererData(renderer:DisplayObject, segment:DataGridSegment):void
        {
            if(segment.headerField && segment.headerField in renderer)
                renderer[segment.headerField] = segment.applyTitle(data);
            else if('data' in renderer)
                renderer['data'] = segment.applyTitle(data);
            
            if('segment' in renderer)
                renderer['segment'] = segment;
            
            if(segment is DataGridSegmentGroup && renderer is DisplayObjectContainer)
            {
                var children:Vector.<DataGridSegment> = DataGridSegmentGroup(segment).children;
                commitSegmentData(children, DisplayObjectContainer(renderer));
            }
        }
        
        override protected function createSegmentRenderer(segment:DataGridSegment, index:int, rendererParent:DisplayObjectContainer):DisplayObject
        {
            var renderer:DisplayObject;
            var factory:IFactory = segment.header;
            var type:Class;
            
            if(factory is ClassFactory)
                type = ClassFactory(factory).generator;
            else
                type = factory.newInstance()['constructor'];
            
            if(!pool.has(type))
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
            
            if(segment is DataGridSegmentGroup && renderer is DisplayObjectContainer)
            {
                createSegmentRenderers(DataGridSegmentGroup(segment).children, DisplayObjectContainer(renderer));
            }
            
            return renderer;
        }
    }
}