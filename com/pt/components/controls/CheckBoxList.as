package com.pt.components.controls
{
  import mx.controls.CheckBox;
  import mx.controls.List;
  import mx.events.ListEvent;

  public class CheckBoxList extends List
  {
    public function CheckBoxList()
    {
      super();
      addEventListener(ListEvent.ITEM_CLICK, listItemClickHandler);
    }
    
    protected function listItemClickHandler(event:ListEvent):void
    {
      var renderer:CheckBox = event.itemRenderer as CheckBox;
      var data:Object = renderer.data;
      if(data.hasOwnProperty("selected"))
      {
        if(renderer.selected && !data.selected)
        {
          data.selected = true;
          renderer.selected = true;
        }
        else if(renderer.selected && data.selected)
        {
          data.selected = false;
          renderer.selected = false;
        }
        else if(!renderer.selected && data.selected)
        {
          data.selected = false;
          renderer.selected = false;
        }
        else if(!renderer.selected && !data.selected)
        {
          data.selected = true;
          renderer.selected = true;
        }
      }
      else
      {
        renderer.selected = !renderer.selected;
      }
    }
  }
}