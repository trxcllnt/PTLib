package com.pt.components.controls
{
  import flash.events.MouseEvent;
  
  import mx.controls.HScrollBar;
  import mx.core.mx_internal;
  
  use namespace mx_internal;
  
  public class RampingHScrollBar extends HScrollBar
  {
    public function RampingHScrollBar()
    {
      super();
    }
    
    override protected function createChildren():void
    {
      super.createChildren();
      if(upArrow)
        upArrow.addEventListener(MouseEvent.MOUSE_UP, mouseUp_handler, false, 0, true);
      if(downArrow)
        downArrow.addEventListener(MouseEvent.MOUSE_UP, mouseUp_handler, false, 0, true);
    }
    
    private function mouseUp_handler(event:MouseEvent):void
    {
      rampingCounter = 0;
    }
    
    private var _rampingThreshold:Number = 10;
    
    public function get rampingThreshold():int
    {
      return _rampingThreshold;
    }
    
    public function set rampingThreshold(value:int):void
    {
      if(value === _rampingThreshold)
        return;
      
      _rampingThreshold = value;
    }
    
    private var rampingCounter:int = 0;
    
    override mx_internal function lineScroll(direction:int):void
    {
      rampingCounter = direction > 0 ? Math.min(rampingCounter + 1, rampingThreshold) : Math.max(rampingCounter - 1, -rampingThreshold);
      
      var delta:Number = lineScrollSize;
      
      var newPos:Number = scrollPosition + direction * delta + rampingCounter;
      if (newPos > maxScrollPosition)
        newPos = maxScrollPosition;
      else if (newPos < minScrollPosition)
        newPos = minScrollPosition;
      
      if (newPos != scrollPosition)
      {
        var oldPosition:Number = scrollPosition;
        scrollPosition = newPos;
        var detail:String = direction < 0 ? lineMinusDetail : linePlusDetail;
        dispatchScrollEvent(oldPosition, detail);
      }
    }
  }
}