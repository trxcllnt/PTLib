package com.pt.components.controls
{
  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.Sprite;
  
  import mx.controls.HScrollBar;
  import mx.controls.VScrollBar;
  import mx.core.IFlexDisplayObject;
  import mx.core.IUIComponent;
  import mx.core.UIComponent;
  import mx.events.ScrollEvent;
  
  [DefaultProperty("target")]
  
  public class Scroller extends UIComponent
  {
    public static const SCROLL_TYPE_MANUAL:String = "manual";
    public static const SCROLL_TYPE_VIRTUAL:String = "virtual";
    
    public function Scroller()
    {
      super();
    }
    
    private var _bars:String = "br";
    
    public function get bars():String
    {
      return _bars.toLowerCase();
    }
    
    public function set bars(value:String):void
    {
      if(value.toLowerCase() == bars)
        return;
      
      removeMask();
      _bars = value;
      invalidateDisplayList();
    }
    
    private var _inset:Boolean = true;
    
    public function get inset():Boolean
    {
      return _inset;
    }
    
    public function set inset(value:Boolean):void
    {
      if(value == _inset)
        return;
      
      removeMask();
      _inset = value;
      invalidateDisplayList();
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
      invalidateDisplayList();
    }
    
    private var _target:DisplayObject;
    
    public function get target():DisplayObject
    {
      return _target;
    }
    
    public function set target(value:DisplayObject):void
    {
      if(value === _target)
        return;
      
      _target = value;
      
      if(!contains(target))
        addChildAt(target, 0);
      
      invalidateDisplayList();
    }
    
    private var _scrollType:String = "manual";
    
    public function get scrollType():String
    {
      return _scrollType;
    }
    
    [Inspectable(category="General", enumeration="manual,virtual", defaultValue="manual")]
    
    public function set scrollType(value:String):void
    {
      if(value != SCROLL_TYPE_MANUAL && value != SCROLL_TYPE_VIRTUAL)
        return;
      
      if(value == _scrollType)
        return;
      
      _scrollType = value;
      invalidateDisplayList();
    }
    
    private var targetHScrollProp:* = "horizontalScrollPosition";
    
    public function set horizontalScrollProperty(prop:*):void
    {
      if(prop === targetHScrollProp)
        return;
      
      if(prop is String || prop is QName)
      {
        targetHScrollProp = prop;
        invalidateDisplayList();
      }
    }
    
    private var targetVScrollProp:* = "verticalScrollPosition";
    
    public function set verticalScrollProperty(prop:*):void
    {
      if(prop === targetVScrollProp)
        return;
      
      if(prop is String || prop is QName)
      {
        targetVScrollProp = prop;
        invalidateDisplayList();
      }
    }
    
    private var targetHProp:* = "height";
    
    public function set heightProperty(prop:*):void
    {
      if(prop === targetHProp)
        return;
      
      if(prop is String || prop is QName)
      {
        targetHProp = prop;
        invalidateDisplayList();
      }
    }
    
    private var targetWProp:* = "width";
    
    public function set widthProperty(prop:*):void
    {
      if(prop === targetWProp)
        return;
      
      if(prop is String || prop is QName)
      {
        targetWProp = prop;
        invalidateDisplayList();
      }
    }
    
    private var _horizontalScrollPosition:Number = 0;
    
    public function get horizontalScrollPosition():Number
    {
      return _horizontalScrollPosition;
    }
    
    public function set horizontalScrollPosition(value:Number):void
    {
      if(value === _horizontalScrollPosition)
        return;
      
      _horizontalScrollPosition = value;
      invalidateDisplayList();
    }
    
    private var _verticalScrollPosition:Number = 0;
    
    public function get verticalScrollPosition():Number
    {
      return _verticalScrollPosition;
    }
    
    public function set verticalScrollPosition(value:Number):void
    {
      if(value === _verticalScrollPosition)
        return;
      
      _verticalScrollPosition = value;
      invalidateDisplayList();
    }
    
    private var _showMask:Boolean = true;
    
    public function get showMask():Boolean
    {
      return _showMask;
    }
    
    public function set showMask(value:Boolean):void
    {
      if(value === _showMask)
        return;
      
      _showMask = value;
      invalidateDisplayList();
    }
    
    override protected function createChildren():void
    {
      super.createChildren();
      
      if(!clipMask)
      {
        clipMask = new Sprite();
        addChild(clipMask);
      }
    }
    
    override protected function updateDisplayList(w:Number, h:Number):void
    {
      super.updateDisplayList(w, h);
      
      if(w <= 0)
        w = parent.width;
      if(h <= 0)
        h = parent.height;
      
      setActualSize(w, h);
      
      if(target)
      {
        sizeTarget(target);
        
        var barCreated:Boolean = configureHorizontalScrollBar(w, h, target[targetWProp]) || configureVerticalScrollBar(h, w, target[targetHProp]);
        
        positionTarget(target);
        
        if(showMask && barCreated)
          removeMask();
        
        showMask ? addMask() : removeMask();
      }
    }
    
    protected function sizeTarget(target:DisplayObject):void
    {
      if(target is IUIComponent)
      {
        var cw:Number = 0;
        var ch:Number = 0;
        
        if(isVirtual)
        {
          cw = unscaledWidth;
          ch = unscaledHeight;
        }
        else
        {
          if(!isNaN(IUIComponent(target).percentWidth))
            cw = unscaledWidth;
          else
            cw = IUIComponent(target).getExplicitOrMeasuredWidth();
          if(!isNaN(IUIComponent(target).percentHeight))
            ch = unscaledHeight;
          else
            ch = IUIComponent(target).getExplicitOrMeasuredHeight();
        }
        
        IUIComponent(target).setActualSize(cw, ch);
      }
    }
    
    protected function positionTarget(target:DisplayObject):void
    {
      var xx:Number = 0;
      var yy:Number = 0;
      if(inset)
      {
        xx -= hasVertical && hasLeft && !hasRight ? 16 : 0;
        yy -= hasHorizontal && hasTop && !hasBottom ? 16 : 0;
      }
      
      if(isVirtual)
      {
        if(targetHScrollProp in target)
          target[targetHScrollProp] = horizontalScrollPosition;
        if(targetVScrollProp in target)
          target[targetVScrollProp] = verticalScrollPosition;
      }
      else
      {
        xx += horizontalScrollPosition;
        yy += verticalScrollPosition;
      }
      
      if(target is IFlexDisplayObject)
      {
        IFlexDisplayObject(target).move(-xx, -yy);
      }
      else
      {
        target.x = -xx;
        target.y = -yy;
      }
    }
    
    public var topBar:RampingHScrollBar;
    public var bottomBar:RampingHScrollBar;
    
    protected function configureHorizontalScrollBar(width:Number, height:Number, totalWidth:Number):Boolean
    {
      var barCreated:Boolean = false
      
      var barWidth:Number = width;
      if(inset)
      {
        barWidth -= (hasVertical && hasLeft) ? 16 : 0;
        barWidth -= (hasVertical && hasRight) ? 16 : 0;
      }
      
      var barX:Number = (hasVertical && hasLeft && inset) ? 16 : 0;
      
      var doTop:Boolean = hasTop && width < totalWidth;
      var doBottom:Boolean = hasBottom && width < totalWidth;
      
      if(doTop)
      {
        if(!topBar)
        {
          barCreated = true;
          topBar = new RampingHScrollBar();
          topBar.addEventListener(ScrollEvent.SCROLL, horizontalScrollHandler);
          addChild(topBar);
        }
        
        topBar.rampingThreshold = rampingThreshold;
        topBar.setScrollProperties(width, 0, totalWidth - width, 0);
        topBar.setActualSize(barWidth, 16);
        topBar.move(barX, inset ? 0 : -16);
        topBar.scrollPosition = horizontalScrollPosition;
      }
      else if(topBar)
      {
        topBar.removeEventListener(ScrollEvent.SCROLL, horizontalScrollHandler);
        removeChild(topBar);
        topBar = null;
      }
      if(doBottom)
      {
        if(!bottomBar)
        {
          barCreated = true;
          bottomBar = new RampingHScrollBar();
          bottomBar.addEventListener(ScrollEvent.SCROLL, horizontalScrollHandler);
          addChild(bottomBar);
        }
        
        bottomBar.rampingThreshold = rampingThreshold;
        bottomBar.setScrollProperties(width, 0, totalWidth - width, 0);
        bottomBar.setActualSize(barWidth, 16);
        bottomBar.move(barX, inset ? height - 16 : height);
        bottomBar.scrollPosition = horizontalScrollPosition;
      }
      else if(bottomBar)
      {
        bottomBar.removeEventListener(ScrollEvent.SCROLL, horizontalScrollHandler);
        removeChild(bottomBar);
        bottomBar = null;
      }
      
      return barCreated;
    }
    
    public var leftBar:RampingVScrollBar;
    public var rightBar:RampingVScrollBar;
    
    protected function configureVerticalScrollBar(height:Number, width:Number, totalHeight:Number):Boolean
    {
      var barCreated:Boolean = false
        
      var barHeight:Number = height;
      if(inset)
      {
        barHeight -= (hasHorizontal && hasTop) ? 16 : 0;
        barHeight -= (hasHorizontal && hasBottom) ? 16 : 0;
      }
      
      var barY:Number = (hasHorizontal && hasTop && inset) ? 16 : 0;
      
      var doLeft:Boolean = hasLeft && height < totalHeight;
      var doRight:Boolean = hasRight && height < totalHeight;
      
      if(doLeft)
      {
        if(!leftBar)
        {
          barCreated = true
          leftBar = new RampingVScrollBar();
          leftBar.addEventListener(ScrollEvent.SCROLL, verticalScrollHandler);
          addChild(leftBar);
        }
        
        leftBar.rampingThreshold = rampingThreshold;
        leftBar.setScrollProperties(height, 0, totalHeight - height, 0);
        leftBar.setActualSize(16, barHeight);
        leftBar.move(inset ? 0 : -16, barY);
        leftBar.scrollPosition = verticalScrollPosition;
      }
      else if(leftBar)
      {
        leftBar.removeEventListener(ScrollEvent.SCROLL, verticalScrollHandler);
        removeChild(leftBar);
        leftBar = null;
      }
      
      if(doRight)
      {
        if(!rightBar)
        {
          barCreated = true
          rightBar = new RampingVScrollBar();
          rightBar.addEventListener(ScrollEvent.SCROLL, verticalScrollHandler);
          addChild(rightBar);
        }
        
        rightBar.rampingThreshold = rampingThreshold;
        rightBar.setScrollProperties(height, 0, totalHeight - height, 0);
        rightBar.setActualSize(16, barHeight);
        rightBar.move(inset ? width - 16 : width, barY);
        rightBar.scrollPosition = verticalScrollPosition;
      }
      else if(rightBar)
      {
        rightBar.removeEventListener(ScrollEvent.SCROLL, verticalScrollHandler);
        removeChild(rightBar);
        rightBar = null;
      }
      
      return barCreated;
    }
    
    private var clipMask:Sprite;
    
    protected function addMask():void
    {
      if(clipMask && target.mask == clipMask)
        return;
      
      var xx:Number = 0;
      var yy:Number = 0;
      var ww:Number = unscaledWidth;
      var hh:Number = unscaledHeight;
      
      if(inset)
      {
        xx += hasVertical && hasLeft ? 16 : 0;
        yy += hasHorizontal && hasTop ? 16 : 0;
        ww -= (hasVertical && hasRight) ? 16 : 0;
        hh -= (hasHorizontal && hasBottom) ? 16 : 0;
        ww -= (hasVertical && hasLeft) ? 16 : 0;
        hh -= (hasHorizontal && hasTop) ? 16 : 0;
      }
      
      var g:Graphics = clipMask.graphics;
      g.beginFill(0xFF0000, 1);
      g.drawRect(xx, yy, ww, hh);
      target.mask = clipMask;
    }
    
    protected function removeMask():void
    {
      if(clipMask)
        clipMask.graphics.clear();
      target.mask = null;
    }
    
    protected function horizontalScrollHandler(event:ScrollEvent):void
    {
      horizontalScrollPosition = event.position;
    }
    
    protected function verticalScrollHandler(event:ScrollEvent):void
    {
      verticalScrollPosition = event.position;
    }
    
    protected function get isVirtual():Boolean
    {
      return scrollType == SCROLL_TYPE_VIRTUAL;
    }
    
    protected function get hasVertical():Boolean
    {
      return target && targetHProp in target && unscaledHeight < target[targetHProp];
    }
    
    protected function get hasHorizontal():Boolean
    {
      return target && targetWProp in target && unscaledWidth < target[targetWProp];
    }
    
    protected function get hasLeft():Boolean
    {
      return bars.indexOf("l") != -1;
    }
    
    protected function get hasRight():Boolean
    {
      return bars.indexOf("r") != -1;
    }
    
    protected function get hasTop():Boolean
    {
      return bars.indexOf("t") != -1;
    }
    
    protected function get hasBottom():Boolean
    {
      return bars.indexOf("b") != -1;
    }
  }
}