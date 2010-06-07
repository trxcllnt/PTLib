package com.pt.components.controls
{
  import com.pt.components.controls.itemRenderers.CheckBoxItemRenderer;
  
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.events.MouseEvent;
  
  import mx.controls.List;
  import mx.controls.listClasses.IListItemRenderer;
  import mx.core.ClassFactory;
  
  public class CheckBoxList extends List
  {
    public function CheckBoxList()
    {
      super();
      
      itemRenderer = new ClassFactory(CheckBoxItemRenderer);
      
      allowMultipleSelection = true;
    }
    
    private var cachedFakeEvent:Event;
    
    override protected function mouseDownHandler(event:MouseEvent):void
    {
      if(event == cachedFakeEvent)
      {
        super.mouseDownHandler(event);
        
        event.stopPropagation();
        
        cachedFakeEvent = null;
        return;
      }
      
      var newEvent:MouseEvent = new MouseEvent(event.type,
                                               event.bubbles,
                                               event.cancelable,
                                               event.localX,
                                               event.localY,
                                               event.relatedObject,
                                               true,
                                               event.altKey,
                                               event.shiftKey,
                                               event.buttonDown,
                                               event.delta);
      
      var target:IEventDispatcher = IEventDispatcher(event.target);
      
      event.preventDefault();
      event.stopImmediatePropagation();
      
      cachedFakeEvent = newEvent;
      
      target.dispatchEvent(newEvent);
    }
    
    override protected function selectItem(item:IListItemRenderer, shiftKey:Boolean, ctrlKey:Boolean, transition:Boolean = true):Boolean
    {
      var changed:Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
      
      var uid:String = itemToUID(item.data);
      toggleCheckBoxItemRenderer(item, uid in selectedData);
      
      return changed;
    }
    
    override protected function drawItem(item:IListItemRenderer, selected:Boolean=false, highlighted:Boolean=false, caret:Boolean=false, transition:Boolean=false):void
    {
      super.drawItem(item, selected, highlighted, caret, transition);
      
      toggleCheckBoxItemRenderer(item, selected);
    }
    
    protected function toggleCheckBoxItemRenderer(item:IListItemRenderer, selected:Boolean):void
    {
      if(!item)
        return;
      
      if('selected' in item)
        item['selected'] = selected;
      if(item.data && 'selected' in item.data)
        item.data['selected'] = selected;
    }
  }
}