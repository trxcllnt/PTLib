package com.pt.components.controls.grid.itemRenderers
{
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.controls.grid.events.HeaderResizeEvent;
    
    import flash.display.DisplayObject;
    
    public class DataGridHeaderBase extends DataGridSegmentRendererBase
    {
        private var dgSize:Number = 0;
        
        public function get dataGridSize():Number
        {
            return dgSize;
        }
        
        public function set dataGridSize(value:Number):void
        {
            if(value === dgSize)
                return;
            
            dgSize = value;
        }
        
        override public function set segments(value:Vector.<DataGridSegment>):void
        {
          if(value === segments)
              return;
          
          while(numChildren)
              removeChildAt(0);
          
          super.segments = value;
        }
      
        override protected function commitRendererData(renderer:DisplayObject, segment:DataGridSegment):void
        {
            if(segment.headerField && segment.headerField in renderer)
            {
                renderer[segment.headerField] = segment.applyTitle(data);
            }
            else if('data' in renderer)
            {
                renderer['data'] = segment.applyTitle(data);
            }
            if('dataGridSize' in renderer)
            {
                renderer['dataGridSize'] = dgSize;
            }
        }
        
        override protected function createSegmentRenderer(segment:DataGridSegment, index:int):DisplayObject
        {
            return createRenderer(segment.header, index);
        }
    }
}