package com.pt.components.containers
{
  
  public class DataContainer extends LayoutContainer
  {
    public function DataContainer()
    {
      super();
    }
    
    protected var dataChanged:Boolean = false;
    
    override public function set data(value:Object):void
    {
      if(value === super.data)
        return;
      
      super.data = value;
      dataChanged = true;
      invalidateProperties();
    }
  }
}