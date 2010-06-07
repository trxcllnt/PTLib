package com.pt.components.controls.itemRenderers
{
  import flash.events.MouseEvent;
  
  import mx.controls.CheckBox;
  import mx.core.mx_internal;
  
  use namespace mx_internal;
  
  public class CheckBoxItemRenderer extends CheckBox
  {
    override public function set data(value:Object):void
    {
      super.data = value;
      
      if(data && 'selected' in data)
        selected = data['selected'];
    }
    
    override mx_internal function setSelected(value:Boolean, isProgrammatic:Boolean = false):void
    {
      super.setSelected(value, isProgrammatic);
      
      if(data && 'selected' in data)
        data['selected'] = value;
    }
    
    override protected function clickHandler(event:MouseEvent):void
    {
      if (!enabled)
        event.stopImmediatePropagation();
      
      // The super impl of this function checks to see if it should toggle the 
      // selected state. We don't want that to happen, as the List control 
      // should have set the selected property already.
    }
  }
}