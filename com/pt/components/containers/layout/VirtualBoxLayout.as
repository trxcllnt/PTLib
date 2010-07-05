package com.pt.components.containers.layout
{
  import com.pt.components.containers.VirtualContainer;
  import com.pt.virtual.Virtual;
  
  import flash.display.DisplayObject;
  import flash.events.IEventDispatcher;
  
  import mx.containers.BoxDirection;
  import mx.containers.utilityClasses.BoxLayout;
  import mx.containers.utilityClasses.Flex;
  import mx.controls.scrollClasses.ScrollBar;
  import mx.core.Container;
  import mx.core.EdgeMetrics;
  import mx.core.IChildList;
  import mx.core.IUIComponent;
  import mx.core.ScrollPolicy;
  import mx.core.mx_internal;
  import mx.events.ChildExistenceChangedEvent;
  import mx.events.ResizeEvent;
  
  use namespace layout;
  use namespace mx_internal;
  
  public class VirtualBoxLayout extends BoxLayout
  {
    public function VirtualBoxLayout()
    {
      super();
    }
    
    override public function measure():void
    {
      if(!virtualContainer.measureLayout)
        super.measure();
    }
    
    override public function updateDisplayList(w:Number, h:Number):void
    {
      var virtual:Virtual = virtualContainer.virtual;
      
      if(virtualContainer.measureLayout)
        virtual.clear();
      
      var xChildren:Array = virtual.getItemsAt(target.horizontalScrollPosition, target.horizontalScrollPosition + w, "x");
      var yChildren:Array = virtual.getItemsAt(target.verticalScrollPosition, target.verticalScrollPosition + h, "y");
      
      var children:Array = union(xChildren, yChildren);
      var childList:IChildList = children.length ? new ArrayChildList(children) : target;
      
      var i:int = 0;
      var n:int = childList.numChildren;
      
      if(childList == target)
        childList = new ArrayChildList(target.getChildren());
      
      target.removeAllChildren();
      
      for(i = 0; i < n; i++)
        target.addChild(childList.getChildAt(i));
      
      var vm:EdgeMetrics = target.viewMetricsAndPadding;
      
      var paddingLeft:Number = target.getStyle("paddingLeft");
      var paddingTop:Number = target.getStyle("paddingTop");
      
      var horizontalAlign:Number = getHorizontalAlignValue();
      var verticalAlign:Number = getVerticalAlignValue();
      
      var mw:Number = target.scaleX > 0 && target.scaleX != 1 ?
        target.minWidth / Math.abs(target.scaleX) :
        target.minWidth;
      var mh:Number = target.scaleY > 0 && target.scaleY != 1 ?
        target.minHeight / Math.abs(target.scaleY) :
        target.minHeight;
      
      w = Math.max(w, mw) - vm.right - vm.left;
      h = Math.max(h, mh) - vm.bottom - vm.top;
      
      var horizontalScrollBar:ScrollBar = target.horizontalScrollBar;
      var verticalScrollBar:ScrollBar = target.verticalScrollBar;
      
      var gap:Number;
      var excessSpace:Number;
      var top:Number;
      var left:Number;
      var obj:IUIComponent;
      var numChildrenWithOwnSpace:int = 0;
      
      if(isVertical()) // VBOX
      {
        gap = target.getStyle("verticalGap");
        
        numChildrenWithOwnSpace = n;
        for(i = 0; i < n; i++)
        {
          if(!IUIComponent(childList.getChildAt(i)).includeInLayout)
            numChildrenWithOwnSpace--;
        }
        
        // Stretch everything as needed, including widths.
        excessSpace = Flex.flexChildHeightsProportionally(
          childList, h - (numChildrenWithOwnSpace - 1) * gap, w);
        
        // Ignore scrollbar sizes for child alignment purpose.
        if(horizontalScrollBar != null &&
          target.horizontalScrollPolicy == ScrollPolicy.AUTO)
        {
          excessSpace += horizontalScrollBar.minHeight;
        }
        if(verticalScrollBar != null &&
          target.verticalScrollPolicy == ScrollPolicy.AUTO)
        {
          w += verticalScrollBar.minWidth;
        }
        
        top = paddingTop + excessSpace * verticalAlign;
        
        for(i = 0; i < n; i++)
        {
          obj = IUIComponent(childList.getChildAt(i))
          if(virtualContainer.measureLayout)
          {
            virtualContainer.virtual.add(obj, obj.width, "x");
            virtualContainer.virtual.add(obj, obj.height, "y");
          }
          left = (w - obj.width) * horizontalAlign + paddingLeft;
          obj.move(Math.floor(left), Math.floor(top));
          if(obj.includeInLayout)
            top += obj.height + gap;
        }
      }
      
      else // HBOX
      {
        gap = target.getStyle("horizontalGap");
        
        numChildrenWithOwnSpace = n;
        for(i = 0; i < n; i++)
        {
          if(!IUIComponent(childList.getChildAt(i)).includeInLayout)
            numChildrenWithOwnSpace--;
        }
        
        // stretch everything as needed including heights
        excessSpace = Flex.flexChildWidthsProportionally(
          childList, w - (numChildrenWithOwnSpace - 1) * gap, h);
        
        // Ignore scrollbar sizes for child alignment purpose.
        if(horizontalScrollBar != null &&
          target.horizontalScrollPolicy == ScrollPolicy.AUTO)
        {
          h += horizontalScrollBar.minHeight;
        }
        if(verticalScrollBar != null &&
          target.verticalScrollPolicy == ScrollPolicy.AUTO)
        {
          excessSpace += verticalScrollBar.minWidth;
        }
        
        left = paddingLeft + excessSpace * horizontalAlign;
        
        for(i = 0; i < n; i++)
        {
          obj = IUIComponent(childList.getChildAt(i));
          if(virtualContainer.measureLayout)
          {
            virtualContainer.virtual.add(obj, obj.width, "x");
            virtualContainer.virtual.add(obj, obj.height, "y");
          }
          top = (h - obj.height) * verticalAlign + paddingTop;
          obj.move(Math.floor(left), Math.floor(top));
          
          if(obj.includeInLayout)
            left += obj.width + gap;
        }
      }
    
      virtualContainer.measureLayout = false;
    }
    
    protected function get virtualContainer():VirtualContainer
    {
      return target as VirtualContainer;
    }
    
    protected function isVertical():Boolean
    {
      return direction != BoxDirection.HORIZONTAL;
    }
  }
}