package com.pt.components.controls.grid.itemRenderers
{
  import com.pt.components.controls.grid.events.HeaderSortEvent;
  
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;

  public class DataGridListHeader extends DataGridHeaderBase
  {
    public function DataGridListHeader()
    {
      super();
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
  }
}