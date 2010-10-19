package com.pt.components.controls
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Mouse;
    
    import mx.controls.scrollClasses.ScrollBar;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;
    import mx.events.ScrollEvent;
    
    [DefaultProperty("target")]
    
    [Style(name="dragCursor", type="Class")]
    [Style(name="horizontalAlign", type="String", enumeration="left,center,right")]
    [Style(name="verticalAlign", type="String", enumeration="top,middle,bottom")]
    
    public class Scroller extends UIComponent
    {
        public static const SCROLL_TYPE_MANUAL:String = "manual";
        public static const SCROLL_TYPE_VIRTUAL:String = "virtual";
        
        public var mouseWheelMultiplier:Number = 1;
        
        public function Scroller()
        {
            super();
            
            addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler);
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
            
            if(followCursor)
                target.addEventListener(MouseEvent.MOUSE_DOWN, cursorDownHandler, false, 0, true);
            
            target.addEventListener(MouseEvent.MOUSE_WHEEL, scrollHandler, false, 0, true);
            
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
        
        protected var targetHScrollProp:* = "horizontalScrollPosition";
        
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
        
        protected var targetVScrollProp:* = "verticalScrollPosition";
        
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
        
        protected var targetHProp:* = "height";
        
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
        
        protected var targetWProp:* = "width";
        
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
        
        protected var _horizontalScrollPosition:Number = 0;
        
        public function get horizontalScrollPosition():Number
        {
            return _horizontalScrollPosition;
        }
        
        public function set horizontalScrollPosition(value:Number):void
        {
            if(value === _horizontalScrollPosition)
                return;
            
            _horizontalScrollPosition = Math.min(Math.max(value, 0), Math.max(Math.round(targetWidth - width), 0));
            
            if(isVirtual)
                target[targetHScrollProp] = _horizontalScrollPosition;
            
            invalidateDisplayList();
        }
        
        protected var _verticalScrollPosition:Number = 0;
        
        public function get verticalScrollPosition():Number
        {
            return _verticalScrollPosition;
        }
        
        public function set verticalScrollPosition(value:Number):void
        {
            if(value === _verticalScrollPosition)
                return;
            
            _verticalScrollPosition = Math.min(Math.max(value, 0), Math.max(Math.round(targetHeight - height), 0));
            
            if(isVirtual)
                target[targetVScrollProp] = _verticalScrollPosition;
            
            invalidateDisplayList();
        }
        
        private var _followCursor:Boolean = false;
        
        public function get followCursor():Boolean
        {
            return _followCursor;
        }
        
        public function set followCursor(value:Boolean):void
        {
            if(value === _followCursor)
                return;
            
            _followCursor = value;
            if(target)
                target.addEventListener(MouseEvent.MOUSE_DOWN, cursorDownHandler, false, 0, true);
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            if(w <= 0 && parent)
              w = parent.width;
            
            if(h <= 0 && parent)
              h = parent.height;
            
            setActualSize(w, h);
            
            if(target)
            {
                sizeTarget(target);
                
                var barCreated:Boolean = configureHorizontalScrollBar(w, h, targetWidth) || configureVerticalScrollBar(h, w, targetHeight);
                
                positionTarget(target);
            }
        }
        
        protected function sizeTarget(target:DisplayObject):void
        {
            if(!(target is IUIComponent))
                return;
            
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
                cw = unscaledWidth * IUIComponent(target).percentWidth * .01;
              else
                cw = IUIComponent(target).getExplicitOrMeasuredWidth();
              if(!isNaN(IUIComponent(target).percentHeight))
                ch = unscaledHeight * IUIComponent(target).percentHeight * .01;
              else
                ch = IUIComponent(target).getExplicitOrMeasuredHeight();
            }
            
            IUIComponent(target).setActualSize(cw, ch);
            
            if(inset)
            {
              cw -= (hasVertical && hasRight) ? 16 : 0;
              ch -= (hasHorizontal && hasBottom) ? 16 : 0;
              cw -= (hasVertical && hasLeft) ? 16 : 0;
              ch -= (hasHorizontal && hasTop) ? 16 : 0;
              
              IUIComponent(target).setActualSize(cw, ch);
            }
        }
        
        protected function positionTarget(target:DisplayObject):void
        {
            var xx:Number = 0
            var yy:Number = 0;
            
            var ww:Number = unscaledWidth;
            var hh:Number = unscaledHeight;
            
            if(inset)
            {
                xx = hasVertical && hasLeft ? 16 : 0;
                yy = hasHorizontal && hasTop ? 16 : 0;
                ww -= (hasVertical && hasRight) ? 16 : 0;
                hh -= (hasHorizontal && hasBottom) ? 16 : 0;
                ww -= (hasVertical && hasLeft) ? 16 : 0;
                hh -= (hasHorizontal && hasTop) ? 16 : 0;
            }
            
            if(target is IUIComponent)
            {
                IUIComponent(target).move(xx, yy);
            }
            else
            {
                target.x = xx;
                target.y = yy;
            }
            
            if(isVirtual)
                return;
            
            xx = horizontalScrollPosition;
            yy = verticalScrollPosition;
            
            if(targetWidth < unscaledWidth)
            {
                var hAlign:String = getStyle('horizontalAlign') || 'left';
                switch(hAlign)
                {
                    case "center":
                        xx = (unscaledWidth - targetWidth) / 2 * -1;
                        break;
                    case "right":
                        xx = unscaledWidth - targetWidth * -1;
                        break;
                }
            }
            
            if(targetHeight < unscaledHeight)
            {
                var vAlign:String = getStyle('verticalAlign') || 'top';
                switch(vAlign)
                {
                    case 'middle':
                        yy = (unscaledHeight - targetHeight) / 2 * -1;
                        break;
                    case 'bottom':
                        yy = unscaledHeight - targetHeight * -1;
                        break;
                }
            }
            
            target.scrollRect = new Rectangle(xx, yy, ww, hh);
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
                
                setScrollBarProperties(topBar,
                                       rampingThreshold,
                                       width, 0, totalWidth - width, 0,
                                       barWidth, 16,
                                       barX, inset ? 0 : -16,
                                       horizontalScrollPosition);
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
                
                setScrollBarProperties(bottomBar,
                                       rampingThreshold,
                                       width, 0, totalWidth - width, 0,
                                       barWidth, 16,
                                       barX, inset ? height - 16 : height,
                                       horizontalScrollPosition);
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
                
                setScrollBarProperties(leftBar,
                                       rampingThreshold,
                                       height, 0, totalHeight - height, 0,
                                       16, barHeight,
                                       inset ? 0 : -16, barY,
                                       verticalScrollPosition);
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
                
                setScrollBarProperties(rightBar,
                                       rampingThreshold,
                                       height, 0, totalHeight - height, 0,
                                       16, barHeight,
                                       inset ? width - 16 : width, barY,
                                       verticalScrollPosition);
            }
            else if(rightBar)
            {
                rightBar.removeEventListener(ScrollEvent.SCROLL, verticalScrollHandler);
                removeChild(rightBar);
                rightBar = null;
            }
            
            return barCreated;
        }
        
        
        protected function setScrollBarProperties(scrollBar:ScrollBar,
                                                  ramping:Number,
                                                  pageSize:Number, minScrollPosition:Number, maxScrollPosition:Number, pageScrollSize:Number,
                                                  barWidth:Number, barHeight:Number,
                                                  barX:Number, barY:Number,
                                                  scrollPosition:Number):void
        {
            if('rampingThreshold' in scrollBar)
                scrollBar['rampingThreshold'] = ramping;
            
            scrollBar.setScrollProperties(pageSize, minScrollPosition, maxScrollPosition, pageScrollSize);
            scrollBar.setActualSize(barWidth, barHeight);
            scrollBar.move(barX, barY);
            scrollBar.scrollPosition = scrollPosition;
        }
        
        protected function horizontalScrollHandler(event:ScrollEvent):void
        {
            horizontalScrollPosition = event.position;
        }
        
        protected function verticalScrollHandler(event:ScrollEvent):void
        {
            verticalScrollPosition = event.position;
        }
        
        protected function scrollHandler(event:MouseEvent):void
        {
            verticalScrollPosition -= (event.delta * mouseWheelMultiplier);
        }
        
        public function get isVirtual():Boolean
        {
            return scrollType == SCROLL_TYPE_VIRTUAL;
        }
        
        public function get hasVertical():Boolean
        {
            var val:Boolean = target && targetHProp in target && unscaledHeight < targetHeight;
            
            if(inset)
              return val;
            
            var h:Number = unscaledHeight;
            if(hasTop && topBar)
              h -= 16;
            if(hasBottom && bottomBar)
              h -= 16;
            
            val ||= h < targetHeight;
            
            return val;
        }
        
        public function get hasHorizontal():Boolean
        {
            var val:Boolean = target && targetWProp in target && unscaledWidth < targetWidth;
            
            if(inset)
              return val;
            
            var w:Number = unscaledWidth;
            if(hasRight && rightBar)
              w -= 16;
            if(hasLeft && leftBar)
              w -= 16;
            
            val ||= w < targetWidth;
            
            return val;
        }
        
        protected function get targetWidth():Number
        {
            if(target[targetWProp] is Function)
                return target[targetWProp]();
            
            return target[targetWProp];
        }
        
        protected function get targetHeight():Number
        {
            if(target[targetHProp] is Function)
                return target[targetHProp]();
            
            return target[targetHProp];
        }
        
        public function get hasLeft():Boolean
        {
            return bars.indexOf("l") != -1;
        }
        
        public function get hasRight():Boolean
        {
            return bars.indexOf("r") != -1;
        }
        
        public function get hasTop():Boolean
        {
            return bars.indexOf("t") != -1;
        }
        
        public function get hasBottom():Boolean
        {
            return bars.indexOf("b") != -1;
        }
        
        private var cursorChild:DisplayObjectContainer;
        
        protected function cursorDownHandler(event:MouseEvent):void
        {
            if(!target)
                return;
            
            var p:Point = new Point(event.stageX, event.stageY);
            coords = p;
            
            if(cursorChild && stage.contains(cursorChild))
                stage.removeChild(cursorChild);
            
            var cursor:Class = getStyle('dragCursor');
            if(cursor)
            {
                Mouse.hide();
                
                cursorChild = DisplayObjectContainer(new cursor());
                cursorChild.mouseChildren = false;
                cursorChild.mouseEnabled = false;
                stage.addChild(cursorChild);
                cursorChild.x = p.x;
                cursorChild.y = p.y;
            }
            
            target.removeEventListener(MouseEvent.MOUSE_DOWN, cursorDownHandler);
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, cursorMoveHandler, true);
            stage.addEventListener(Event.MOUSE_LEAVE, cursorUpHandler, true);
            stage.addEventListener(MouseEvent.MOUSE_UP, cursorUpHandler, true);
        }
        
        private var coords:Point;
        
        protected function cursorMoveHandler(event:MouseEvent):void
        {
            if(!hasHorizontal && !hasVertical)
                return;
            
            var p:Point = new Point(event.stageX, event.stageY);
            
            if(cursorChild)
            {
                cursorChild.x = p.x;
                cursorChild.y = p.y;
            }
            
            var delta:Point = p.subtract(coords);
            horizontalScrollPosition -= delta.x;
            verticalScrollPosition -= delta.y;
            
            coords = p;
        }
        
        protected function cursorUpHandler(event:Event):void
        {
            Mouse.show();
            
            if(cursorChild && stage.contains(cursorChild))
                stage.removeChild(cursorChild);
            
            cursorChild = null;
            
            stage.removeEventListener(Event.MOUSE_LEAVE, cursorUpHandler);
            stage.removeEventListener(MouseEvent.MOUSE_UP, cursorUpHandler, true);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, cursorMoveHandler, true);
            
            if(target)
                target.addEventListener(MouseEvent.MOUSE_DOWN, cursorDownHandler, false, 0, true);
        }
    }
}