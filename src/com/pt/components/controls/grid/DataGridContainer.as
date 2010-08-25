package com.pt.components.controls.grid
{
    import com.pt.components.controls.grid.events.HeaderResizeEvent;
    import com.pt.components.controls.grid.events.HeaderSortEvent;
    import com.pt.components.controls.grid.itemRenderers.DataGridHeaderBase;
    import com.pt.components.controls.grid.itemRenderers.DataGridHeaderRenderer;
    import com.pt.components.controls.grid.itemRenderers.DataGridListHeader;
    import com.pt.virtual.Dimension;
    
    import flash.display.Shape;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.containers.BoxDirection;
    import mx.core.IInvalidating;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    
    public class DataGridContainer extends UIComponent
    {
        public function DataGridContainer()
        {
            super();
            addEventListener(HeaderSortEvent.SORT, onSortHeader);
        }
        
        private var _headerSize:Number;
        
        public function get headerSize():Number
        {
            var retVal:Number = 0;
            
            if(header)
                retVal = isV() ? header.getExplicitOrMeasuredHeight() : header.getExplicitOrMeasuredWidth();
            
            return isNaN(_headerSize) ? retVal : _headerSize;
        }
        
        public function set headerSize(value:Number):void
        {
            if(value === _headerSize)
                return;
            
            _headerSize = value;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        protected function isV():Boolean
        {
            return direction == BoxDirection.VERTICAL;
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
            
            if(header)
                header.data = dataProvider;
            if(list)
                list.dataProvider = dataProvider;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        private var _direction:String = BoxDirection.VERTICAL;
        
        [Inspectable(type="String", enumeration="vertical,horizontal")]
        
        public function get direction():String
        {
            return _direction;
        }
        
        public function set direction(value:String):void
        {
            if(value === _direction)
                return;
            
            _direction = value;
            
            if(header)
                header.direction = segmentDirection;
            if(list)
                list.direction = value;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        protected function get segmentDirection():String
        {
            if(direction == BoxDirection.HORIZONTAL)
                return BoxDirection.VERTICAL;
            
            return BoxDirection.HORIZONTAL;
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
            
            if(list)
                list.itemSize = itemSize;
            
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
            
            if(list)
                list.variableItemSize = variableItemSize;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        private var scrollPosition:Point = new Point();
        
        public function get horizontalScrollPosition():Number
        {
            return scrollPosition.x;
        }
        
        public function set horizontalScrollPosition(value:Number):void
        {
            if(scrollPosition.x === value)
                return;
            
            newRendererInView.x = int((value < scrollPosition.x) ? value <= scrollDelta[1].x : value + width >= scrollDelta[1].y);
            
            scrollPosition.x = value;
            
            if(newRendererInView.x)
            {
                lastRendererScrollPosition.x = value;
                if(isV())
                {
                    processSegments();
                }
            }
            
            if(list)
            {
                list.horizontalScrollPosition = scrollPosition.x;
            }
            
            invalidateDisplayList();
        }
        
        public function get verticalScrollPosition():Number
        {
            return scrollPosition.y;
        }
        
        public function set verticalScrollPosition(value:Number):void
        {
            if(scrollPosition.y === value)
                return;
            
            newRendererInView.y = int((value < scrollPosition.y) ? value <= scrollDelta[0].x : value + height >= scrollDelta[0].y);
            
            scrollPosition.y = value;
            
            if(newRendererInView.y)
            {
                lastRendererScrollPosition.y = value;
                if(!isV())
                {
                    processSegments();
                }
            }
            
            if(list)
            {
                list.verticalScrollPosition = scrollPosition.y;
            }
            
            invalidateDisplayList();
        }
        
        protected function setScrollProperties():void
        {
            if(header)
            {
                header.scrollRect = new Rectangle(isV() ? horizontalScrollPosition : 0,
                                                  isV() ? 0 : verticalScrollPosition,
                                                  isV() ? unscaledWidth : header.width,
                                                  isV() ? header.height : unscaledHeight);
            }
            
            if(list)
            {
                gfx.scrollRect = list.scrollRect;
            }
        }
        
        protected var _segments:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
        private var segmentDimension:Dimension = new Dimension();
        private var segmentsChanged:Boolean = false;
        
        public function get segments():Vector.<DataGridSegment>
        {
            return _segments;
        }
        
        public function set segments(value:Vector.<DataGridSegment>):void
        {
            if(value === _segments)
                return;
            
            _segments = value;
            segmentsChanged = true;
            
            if(header)
                header.segments = segments;
            
            if(list)
                list.segments = segments;
            
            invalidateDisplayList();
        }
        
        protected var list:DataGridList;
        protected var header:DataGridHeaderBase;
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            list = new DataGridList();
            list.direction = direction;
            list.segments = segments;
            list.itemSize = itemSize;
            list.variableItemSize = variableItemSize;
            addChild(list);
            
            header = new DataGridListHeader();
            header.segments = segments;
            header.direction = segmentDirection;
            header.addEventListener(HeaderResizeEvent.RESIZE, onHeaderResize);
            addChild(header);
            
            gfx = new Shape();
            addChild(gfx);
        }
        
        override protected function measure():void
        {
            super.measure();
            
            if(isV())
            {
                measuredWidth = segmentDimension.size;
                measuredHeight = list.getExplicitOrMeasuredHeight() + headerSize;
            }
            else
            {
                measuredWidth = list.getExplicitOrMeasuredWidth() + headerSize;
                measuredHeight = segmentDimension.size;
            }
        }
        
        protected var scrollDelta:Vector.<Point> = Vector.<Point>([new Point(), new Point()]);
        protected var lastRendererScrollPosition:Point = new Point(-10000, -10000);
        protected var newRendererInView:Point = new Point();
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            if(segmentsChanged)
            {
                addEventListener(FlexEvent.UPDATE_COMPLETE, onSegmentsChangedUpdateComplete);
            }
            
            setScrollProperties();

            if(isV())
            {
                header.setActualSize(w, headerSize);
                header.dataGridSize = h;
                
                list.setActualSize(w, h - headerSize);
                list.move(0, headerSize);
                
                gfx.x = 0;
                gfx.y = headerSize;
            }
            else
            {
                header.setActualSize(headerSize, h);
                header.dataGridSize = w;
                
                list.setActualSize(w - headerSize, h);
                list.move(headerSize, 0);
                
                gfx.x = headerSize;
                gfx.y = 0;
            }
            
            newRendererInView.x = 0;
            newRendererInView.y = 0;
        }
        
        protected function processSegments():void
        {
            if(!(segmentsChanged || newRendererInView.x || newRendererInView.y))
              return;
            
            var minPosition:Number = isV() ? horizontalScrollPosition : verticalScrollPosition;
            var maxPosition:Number = minPosition + (isV() ? width : height);
            var items:Array = segmentDimension.getBetween(minPosition, maxPosition);
            
            var visibleSegments:Vector.<DataGridSegment> = Vector.<DataGridSegment>(items);
            header.segments = visibleSegments;
            list.segments = visibleSegments;
            
            if(visibleSegments.length)
            {
                var scrollIndex:int = isV() ? 1 : 0;
                var segment:DataGridSegment = visibleSegments[0];
                scrollDelta[scrollIndex].x = segmentDimension.getPosition(segment);
                segment = visibleSegments[visibleSegments.length - 1];
                scrollDelta[scrollIndex].y = segmentDimension.getPosition(segment) + segmentDimension.getSize(segment);
            }
            
            header.addEventListener(FlexEvent.UPDATE_COMPLETE, onHeaderUpdateComplete);
        }
        
        private function onSegmentsChangedUpdateComplete(event:FlexEvent):void
        {
            removeEventListener(FlexEvent.UPDATE_COMPLETE, onSegmentsChangedUpdateComplete);
            
            segmentDimension.clear();
            
            var n:int = segments.length;
            var segment:DataGridSegment
            for(var i:int = 0; i < n; ++i)
            {
                segment = segments[i];
                segmentDimension.add(segment, segment.size);
            }
            
            processSegments();
            
            segmentsChanged = false;
            
            if(isV())
            {
                measuredWidth = segmentDimension.size;
                measuredHeight = list.getExplicitOrMeasuredHeight() + headerSize;
            }
            else
            {
                measuredWidth = list.getExplicitOrMeasuredWidth() + headerSize;
                measuredHeight = segmentDimension.size;
            }
            
            var p:IInvalidating = parent as IInvalidating;
            if (!p)
              return;
            
            p.invalidateSize();
            p.invalidateDisplayList();
        }
        
        protected function onSortHeader(event:HeaderSortEvent):void
        {
            var segment:DataGridSegment = DataGridHeaderRenderer(event.target).segment;
            
            for(var i:int = 0; i < segments.length; ++i)
                segments[i].selected = segments[i] == segment;
            
            dataProvider = segment.applySort((dataProvider as Array).concat(), event.ascending);
        }
        
        protected function onHeaderResize(event:HeaderResizeEvent):void
        {
            segmentsChanged = true;
            invalidateDisplayList();
        }
        
        protected function onHeaderUpdateComplete(event:FlexEvent):void
        {
            header.removeEventListener(event.type, onHeaderUpdateComplete);
            
            gfx.graphics.clear();
            drawSegmentLines(header.segments);
        }
        
        private var gfx:Shape;
        
        private function drawSegmentLines(segments:Vector.<DataGridSegment>):void
        {
          var n:int = segments.length;
          var segment:DataGridSegment;
          var pt:Point;
          
          for(var i:int = 0; i < n; ++i)
          {
            segment = segments[i];
            
            if(segment is DataGridSegmentGroup)
            {
                drawSegmentLines(DataGridSegmentGroup(segment).children);
            }
            else
            {
                pt = segment.getRelativePosition();
                pt[isV() ? 'x' : 'y'] += segment.size;
                gfx.graphics.lineStyle(1, 0xCCCCCC);
                gfx.graphics.moveTo(isV() ? pt.x : 0, isV() ? 0 : pt.y);
                gfx.graphics.lineTo(isV() ? pt.x : list.getExplicitOrMeasuredWidth(), isV() ? list.getExplicitOrMeasuredHeight() : pt.y);
            }
          }
        }
    }
}