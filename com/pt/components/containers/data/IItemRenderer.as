package com.pt.components.containers.data
{
  import flash.geom.Rectangle;
  
  import mx.core.IDataRenderer;
  
  public interface IItemRenderer extends IDataRenderer
  {
    function getDimensions(data:Object = null):Rectangle;
  }
}