package com.pt.components.containers
{
  
  import mx.containers.utilityClasses.BoxLayout;
  import mx.containers.utilityClasses.CanvasLayout;
  import mx.containers.utilityClasses.ConstraintColumn;
  import mx.containers.utilityClasses.ConstraintRow;
  import mx.containers.utilityClasses.IConstraintLayout;
  import mx.containers.utilityClasses.Layout;
  import mx.core.Container;
  import mx.core.ContainerLayout;
  import mx.core.IUIComponent;
  import mx.core.mx_internal;
  
  use namespace mx_internal;
  
  /**
   *  Horizontal alignment of children in the container.
   *  Possible values are <code>"left"</code>, <code>"center"</code>,
   *  and <code>"right"</code>.
   *  The default value is <code>"left"</code>, but some containers,
   *  such as ButtonBar and ToggleButtonBar,
   *  have different default values.
   */
  [Style(name="horizontalAlign", type="String", enumeration="left,center,right", inherit="no")]
  
  /**
   *  Vertical alignment of children in the container.
   *  Possible values are <code>"top"</code>, <code>"middle"</code>,
   *  and <code>"bottom"</code>.
   *  The default value is <code>"top"</code>, but some containers,
   *  such as ButtonBar, ControlBar, LinkBar,
   *  and ToggleButtonBar, have different default values.
   */
  [Style(name="verticalAlign", type="String", enumeration="bottom,middle,top", inherit="no")]
  
  /**
   *  Number of pixels between children in the horizontal direction.
   *  The default value is 8.
   *  
   *  @langversion 3.0
   *  @playerversion Flash 9
   *  @playerversion AIR 1.1
   *  @productversion Flex 3
   */
  [Style(name="horizontalGap", type="Number", format="Length", inherit="no")]
  
  /**
   *  Number of pixels between children in the vertical direction.
   *  The default value is 8.
   *  
   *  @langversion 3.0
   *  @playerversion Flash 9
   *  @playerversion AIR 1.1
   *  @productversion Flex 3
   */
  [Style(name="verticalGap", type="Number", format="Length", inherit="no")]
  
  /**
   *  Number of pixels between the container's bottom border
   *  and the bottom of its content area.
   *  The default value is 0.
   */
  [Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
  
  /**
   *  Number of pixels between the container's top border
   *  and the top of its content area.
   *  The default value is 0.
   */
  [Style(name="paddingTop", type="Number", format="Length", inherit="no")]
  
  public class LayoutContainer extends Container implements IConstraintLayout
  {
    public function LayoutContainer()
    {
      super();
      //Default to absolute (CanvasLayout)
//      layout = ContainerLayout.ABSOLUTE;
    }
    
    override mx_internal function get usePadding():Boolean
    {
      // We never use padding unless we're a box.
      return isBox();
    }
    
    protected var layoutObject:Layout;
    
    public function get layout():Layout
    {
      return layoutObject;
    }
    
    protected var layouts:Object = {horizontal:BoxLayout, vertical:BoxLayout, absolute:CanvasLayout};
    
    [Inspectable(category="General", defaultValue="absolute", enumeration="vertical,horizontal,absolute")]
    
    public function set layout(value:*):void
    {
      setLayout(value).target = this;
    }
    
    protected function setLayout(value:*):Layout
    {
      if(layout)
      {
        layout.target = null;
      }
      
      var layoutClass:Class;
      if(value is String && (value in layouts))
      {
        if(layout)
        {
          layoutClass = layouts[value];
          if(layout is layoutClass)
          {
            if(layout is BoxLayout)
            {
              if(BoxLayout(layout).direction == value)
                return layout;
            }
            else
              return layout;
          }
        }
        
        layoutObject = new layouts[value]();
        
        if(layout is BoxLayout)
          BoxLayout(layout).direction = value;
      }
      else if(value is Layout)
      {
        if(value != layout)
        {
          layoutObject = value;
        }
      }
      else
        throw new ArgumentError("Can't set anything but a String direction or Layout value as the layout for a DataContainer.");
      
      return layoutObject;
    }
    
    /**
     *  @private
     *  Storage for the constraintColumns property.
     */
    private var _constraintColumns:Array = [];
    
    [ArrayElementType("mx.containers.utilityClasses.ConstraintColumn")]
    [Inspectable(arrayType="mx.containers.utilityClasses.ConstraintColumn")]
    
    /**
     *  @copy mx.containers.utilityClasses.IConstraintLayout#constraintColumns
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get constraintColumns():Array
    {
      return _constraintColumns;
    }
    
    /**
     *  @private
     */
    public function set constraintColumns(value:Array):void
    {
      if(value != _constraintColumns)
      {
        var n:int = value.length;
        for(var i:int = 0; i < n; i++)
        {
          ConstraintColumn(value[i]).container = this;
        }
        _constraintColumns = value;
        
        invalidateSize();
        invalidateDisplayList();
      }
    }
    
    //----------------------------------
    //  constraintRows
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the constraintRows property.
     */
    private var _constraintRows:Array = [];
    
    [ArrayElementType("mx.containers.utilityClasses.ConstraintRow")]
    [Inspectable(arrayType="mx.containers.utilityClasses.ConstraintRow")]
    
    /**
     *  @copy mx.containers.utilityClasses.IConstraintLayout#constraintRows
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get constraintRows():Array
    {
      return _constraintRows;
    }
    
    /**
     *  @private
     */
    public function set constraintRows(value:Array):void
    {
      if(value != _constraintRows)
      {
        var n:int = value.length;
        for(var i:int = 0; i < n; i++)
        {
          ConstraintRow(value[i]).container = this;
        }
        _constraintRows = value;
        
        invalidateSize();
        invalidateDisplayList();
      }
    }
    
    public function pixelsToPercent(pxl:Number):Number
    {
      var vertical:Boolean = isVertical;
      
      // Compute our total percent and total # pixels for that percent.
      var totalPerc:Number = 0;
      var totalSize:Number = 0;
      
      var n:int = numChildren;
      for (var i:int = 0; i < n; i++)
      {
        var child:IUIComponent = IUIComponent(getChildAt(i));
        
        var size:Number = vertical ? child.height : child.width;
        var perc:Number = vertical ? child.percentHeight : child.percentWidth;
        
        if (!isNaN(perc))
        {
          totalPerc += perc;
          totalSize += size;
        }
      }
      
      // Now if we found one let's compute the percent amount
      // that we'd require for a given number of pixels.
      var p:Number = 100;
      if (totalSize != pxl)
      {
        // Now we want the ratio of pixels per percent to
        // remain constant as we assume the a component
        // will consume them. So,
        //
        //  (totalSize - pxl) / totalPerc = totalSize / (totalPerc + p)
        //
        // where we solve for p.
        
        p = ((totalSize * totalPerc) / (totalSize - pxl)) - totalPerc;
      }
      
      return p;
    }
    
    protected function isBox():Boolean
    {
      return (layout is BoxLayout);
    }
    
    protected function get isVertical():Boolean
    {
      return isBox() && (BoxLayout(layout).direction == ContainerLayout.VERTICAL);
    }
    
    override protected function measure():void
    {
      super.measure();
      
      layoutObject.measure();
    }
    
    override protected function updateDisplayList(w:Number, h:Number):void
    {
      super.updateDisplayList(w, h);
      
      layoutObject.updateDisplayList(w, h);
    }
  }
}