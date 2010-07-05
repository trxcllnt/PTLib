package com.pt.components.containers
{
  import com.pt.components.containers.layout.VirtualBoxLayout;
  import com.pt.components.containers.layout.VirtualCanvasLayout;
  import com.pt.components.containers.layout.layout;
  import com.pt.virtual.Virtual;
  
  import mx.containers.utilityClasses.BoxLayout;
  import mx.containers.utilityClasses.CanvasLayout;
  import mx.containers.utilityClasses.Layout;
  
  use namespace layout;
  
  public class VirtualContainer extends LayoutContainer
  {
    public function VirtualContainer()
    {
      super();
    }
    
    override protected function setLayout(value:*):Layout
    {
      value = super.setLayout(value);
      
      if(value is BoxLayout)
      {
        value = new VirtualBoxLayout();
        value.direction = layoutObject['direction'];
      }
      else if(value is CanvasLayout)
        value = new VirtualCanvasLayout();
      
      layoutObject = value;
      
      return layoutObject;
    }
    
    layout var virtual:Virtual = new Virtual("x", "y", "z");
    layout var measureLayout:Boolean = true;
  }
}
