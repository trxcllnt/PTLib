package com.pt.components.controls.grid.events
{
  import flash.events.Event;
  
  public class HeaderSortEvent extends Event
  {
    public static const SORT:String = 'sortSegment';
    public static const UNSORT:String = 'unSortSegment';
    
    public function HeaderSortEvent(type:String, ascending:Boolean = false)
    {
      super(type, true, true);
      asc = ascending;
    }
    
    private var asc:Boolean = false;
    public function get ascending():Boolean
    {
      return asc;
    }
  }
}