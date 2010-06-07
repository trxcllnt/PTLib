package com.pt.components.controls
{
  import mx.controls.List;
  import mx.controls.listClasses.IListItemRenderer;
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
      var renderer:IListItemRenderer = event.itemRenderer as IListItemRenderer;
      var data:Object = renderer.data;
      
      if('selected' in data && 'selected' in renderer)
      {
        data['selected'] = renderer['selected'] =  (renderer['selected'] && data['selected'] == false) || (renderer['selected'] == false && data['selected'] == false);
      }
      else if('selected' in renderer)
        renderer['selected'] = !renderer['selected'];
      else if('selected' in data)
        data['selected'] = !data['selected'];
    }
  }
}