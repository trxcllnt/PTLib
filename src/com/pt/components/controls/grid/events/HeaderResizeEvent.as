package com.pt.components.controls.grid.events
{
  import flash.events.Event;
  
  public class HeaderResizeEvent extends Event
  {
    public static const RESIZE:String = 'headerResize';
    
    public function HeaderResizeEvent()
    {
      super(RESIZE, true, true);
    }
  }
}