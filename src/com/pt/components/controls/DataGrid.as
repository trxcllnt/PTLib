package com.pt.components.controls
{
    import com.pt.components.controls.grid.DataGridContainer;
    import com.pt.components.controls.grid.DataGridSegment;
    
    import flash.display.DisplayObject;
    
    import mx.controls.scrollClasses.ScrollBar;
    import mx.core.IUIComponent;
    
    public class DataGrid extends Scroller
    {
        public function DataGrid()
        {
            super();
            heightProperty = 'getExplicitOrMeasuredHeight';
            widthProperty = 'getExplicitOrMeasuredWidth';
            scrollType = SCROLL_TYPE_VIRTUAL;
            rampingThreshold = 200;
            followCursor = true;
            inset = false;
        }
        
        private var _dataProvider:Object;
        
        public function get dataProvider():Object
        {
            return _dataProvider;
        }
        
        public function set dataProvider(value:Object):void
        {
            if(value === _dataProvider)
                return;
            
            _dataProvider = value;
            
            if(container)
                container.dataProvider = dataProvider;
            
            horizontalScrollPosition = 0;
            verticalScrollPosition = 0;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        private var _headerSize:Number;
        
        public function get headerSize():Number
        {
            return _headerSize;
        }
        
        public function set headerSize(value:Number):void
        {
            if(value === _headerSize)
                return;
            
            _headerSize = value;
            
            if(container)
                container.headerSize = headerSize;
            
            invalidateDisplayList();
        }
        
        private var _itemSize:Number = NaN;
        
        public function get itemSize():Number
        {
            return _itemSize;
        }
        
        public function set itemSize(value:Number):void
        {
            if(value === _itemSize)
                return;
            
            _itemSize = value;
            if(isNaN(value))
                variableItemSize = true;
            
            if(container)
                container.itemSize = itemSize;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        private var _variableItemSize:Boolean = false;
        
        public function get variableItemSize():Boolean
        {
            return _variableItemSize;
        }
        
        public function set variableItemSize(value:Boolean):void
        {
            if(_variableItemSize === value)
                return;
            
            _variableItemSize = value;
            
            if(variableItemSize == false && isNaN(itemSize))
                _itemSize = 25;
            
            if(container)
                container.variableItemSize = variableItemSize;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        protected var _segments:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
        
        public function get segments():Vector.<DataGridSegment>
        {
            return _segments;
        }
        
        public function set segments(value:Vector.<DataGridSegment>):void
        {
            if(value === _segments)
                return;
            
            _segments = value;
            
            if(container)
                container.segments = segments;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        override public function set horizontalScrollPosition(value:Number):void
        {
          if(value === _horizontalScrollPosition)
            return;
          
          var tw:Number = targetWidth;
          tw += (hasVertical && hasRight) ? 16 : 0;
          tw += (hasVertical && hasLeft) ? 16 : 0;
          
          _horizontalScrollPosition = Math.min(Math.max(value, 0), Math.max(Math.round(tw - width), 0));
          
          if(isVirtual)
            target[targetHScrollProp] = _horizontalScrollPosition;
          
          invalidateDisplayList();
        }
        
        override public function set verticalScrollPosition(value:Number):void
        {
          if(value === _verticalScrollPosition)
            return;
          
          var th:Number = targetHeight;
          th += (hasHorizontal && hasBottom) ? 16 : 0;
          th += (hasHorizontal && hasTop) ? 16 : 0;
          
          _verticalScrollPosition = Math.min(Math.max(value, 0), Math.max(Math.round(th - height), 0));
          
          if(isVirtual)
            target[targetVScrollProp] = _verticalScrollPosition;
          
          invalidateDisplayList();
        }
        
        protected var container:DataGridContainer;
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            if(!container)
              container = new DataGridContainer();
            
            target = container;
            
            container.dataProvider = dataProvider;
            container.headerSize = headerSize;
            container.segments = segments;
            container.itemSize = itemSize;
            container.variableItemSize = variableItemSize;
        }
        
        override protected function measure():void
        {
            super.measure();
            
            measuredWidth = explicitWidth || 400;
            measuredHeight = explicitHeight || 250;
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            if(w <= 0 || h <= 0)
            {
                w = w || parent.width;
                h = h || parent.height;
                setActualSize(w, h);
            }
            
            if(target)
            {
                sizeTarget(target);
                
                var tw:Number = targetWidth;
                tw += (hasVertical && hasRight) ? 16 : 0;
                tw += (hasVertical && hasLeft) ? 16 : 0;
                
                var th:Number = targetHeight;
                th += (hasHorizontal && hasBottom) ? 16 : 0;
                th += (hasHorizontal && hasTop) ? 16 : 0;
                
                configureHorizontalScrollBar(w, h, tw);
                configureVerticalScrollBar(h, w, th);
                
                positionTarget(target);
            }
        }
        
        override protected function sizeTarget(target:DisplayObject):void
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
                    cw = unscaledWidth;
                else
                    cw = IUIComponent(target).getExplicitOrMeasuredWidth();
                if(!isNaN(IUIComponent(target).percentHeight))
                    ch = unscaledHeight;
                else
                    ch = IUIComponent(target).getExplicitOrMeasuredHeight();
            }
            
            if(ch < targetHeight)
            {
              if(hasRight)
                cw -= 16;
              if(hasLeft)
                cw -= 16;
            }
            if(cw < targetWidth)
            {
              if(hasTop)
                ch -= 16;
              if(hasBottom)
                ch -= 16;
            }
            
            IUIComponent(target).setActualSize(cw, ch);
        }
        
        override protected function setScrollBarProperties(scrollBar:ScrollBar,
                                                           ramping:Number,
                                                           pageSize:Number, minScrollPosition:Number, maxScrollPosition:Number, pageScrollSize:Number,
                                                           barWidth:Number, barHeight:Number,
                                                           barX:Number, barY:Number,
                                                           scrollPosition:Number):void
        {
            if((scrollBar == leftBar || scrollBar == rightBar))
            {
                barY += container.headerSize;
                barHeight -= container.headerSize;
                
                if(!hasTop)
                    barX -= 16;
                if(hasHorizontal && hasBottom)
                    barHeight -= 16;
            }
            else if(scrollBar == topBar || scrollBar == bottomBar)
            {
                if(!hasLeft)
                    barY -= 16;
                if(hasVertical && hasRight)
                    barWidth -= 16;
            }
            
            super.setScrollBarProperties(scrollBar,
                                         ramping,
                                         pageSize, minScrollPosition, maxScrollPosition, pageScrollSize,
                                         barWidth, barHeight,
                                         barX, barY,
                                         scrollPosition);
        }
    }
}