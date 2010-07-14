package com.pt.components.controls.grid
{
    import com.pt.components.controls.itemRenderers.DataGridListHeaderRenderer;
    import com.pt.virtual.Dimension;
    
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.containers.BoxDirection;
    import mx.core.UIComponent;
    
    public class DataGridContainer extends UIComponent
    {
        public function DataGridContainer()
        {
            super();
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
            
            newRendererInView.x = int((value < scrollPosition.x) ?
                                      value <= scrollDelta[1].x :
                                      value + width >= scrollDelta[1].y);
            
            scrollPosition.x = value;
            
            if(newRendererInView.x)
            {
                lastRendererScrollPosition.x = value;
                if(isV())
                    processSegments();
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
            
            newRendererInView.y = int((value < scrollPosition.y) ?
                                      value <= scrollDelta[0].x :
                                      value + height >= scrollDelta[0].y);
            
            scrollPosition.y = value;
            
            if(newRendererInView.y)
            {
                lastRendererScrollPosition.y = value;
                if(!isV())
                    processSegments();
            }
            
            invalidateDisplayList();
        }
        
        protected function setScrollProperties():void
        {
            if(header)
            {
                header.scrollRect = new Rectangle(
                    isV() ? horizontalScrollPosition : 0,
                    isV() ? 0 : verticalScrollPosition,
                    isV() ? unscaledWidth : header.width,
                    isV() ? header.height : unscaledHeight);
            }
            
            if(list)
            {
                list.horizontalScrollPosition = scrollPosition.x;
                list.verticalScrollPosition = scrollPosition.y;
            }
        }
        
        protected var _segments:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
        protected var visibleSegments:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
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
            visibleSegments = _segments;
            segmentsChanged = true;
            
            if(header)
                header.segments = segments;
            if(list)
                list.segments = segments;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        protected var list:DataGridList;
        protected var header:DataGridListHeaderRenderer;
        private var gfx:Shape;
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            header = new DataGridListHeaderRenderer();
            header.segments = segments;
            header.direction = segmentDirection;
            addChild(header);
            
            list = new DataGridList();
            list.direction = direction;
            list.segments = segments;
            list.itemSize = itemSize;
            list.variableItemSize = variableItemSize;
            addChild(list);
            
            gfx = new Shape();
            addChild(gfx);
        }
        
        protected function processSegments():void
        {
            if(!(segmentsChanged || newRendererInView.x || newRendererInView.y))
                return;
            
            var minPosition:Number = isV() ? horizontalScrollPosition : verticalScrollPosition;
            var maxPosition:Number = minPosition + (isV() ? width : height);
            var items:Array = segmentDimension.getBetween(minPosition, maxPosition);
            visibleSegments = Vector.<DataGridSegment>(items);
            header.segments = visibleSegments;
            list.segments = visibleSegments;
        }
        
        override protected function measure():void
        {
            super.measure();
            
            if(segmentsChanged)
            {
                segmentDimension.clear();
                var segment:DataGridSegment;
                var n:int = segments.length;
                
                for(var i:int = 0; i < n; i++)
                {
                    segment = segments[i];
                    
                    measureSegment(segment);
                    
                    segmentDimension.add(segment, segment.size);
                }
            }
            
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
            
            if(segmentsChanged)
                processSegments();
        }
        
        private function measureSegment(segment:DataGridSegment):void
        {
            if(segment is DataGridSegmentGroup)
            {
                var children:Vector.<DataGridSegment> = DataGridSegmentGroup(segment).children;
                var n:int = children.length;
                var size:Number = 0;
                for(var i:int = 0; i < n; i++)
                {
                    measureSegment(children[i]);
                    size += children[i].size;
                }
                
                segment.size = size;
            }
            else
            {
                if(isNaN(segment.size))
                {
                    segment.size = segment.measuredSize;
                }
            }
        }
        
        protected var scrollDelta:Vector.<Point> = Vector.<Point>([new Point(), new Point()]);
        protected var lastRendererScrollPosition:Point = new Point(-10000, -10000);
        protected var newRendererInView:Point = new Point();
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            setScrollProperties();
            
            var g:Graphics = graphics;
            g.clear();
            g.beginFill(0x00, 0);
            g.drawRect(0, 0, w, h);
            
            var i:int;
            if(segmentsChanged)
            {
                var n:int = segments.length;
                var c:Number = 0;
                
                for(i = 0; i < n; i++)
                {
                    c = positionSegment(segments[i], c);
                }
            }
            
            g = gfx.graphics;
            g.clear();
            g.lineStyle(1, 0xCCCCCC);
            
            if(visibleSegments.length)
            {
                drawSegmentPartitions(visibleSegments);
                
                var scrollIndex:int = isV() ? 1 : 0;
                var segment:DataGridSegment = visibleSegments[0];
                scrollDelta[scrollIndex].x = segmentDimension.getPosition(segment);
                segment = visibleSegments[visibleSegments.length - 1];
                scrollDelta[scrollIndex].y = segmentDimension.getPosition(segment) + segmentDimension.getSize(segment);
            }
            
            if(isV())
            {
                header.setActualSize(w, headerSize);
                g.moveTo(0, header.height);
                g.lineTo(w, header.height);
                
                list.setActualSize(w, h - headerSize);
                list.move(0, headerSize);
            }
            else
            {
                header.setActualSize(headerSize, h);
                g.moveTo(header.width, 0);
                g.lineTo(header.width, h);
                
                list.setActualSize(w - headerSize, h);
                list.move(headerSize, 0);
            }
            
            g.drawRect(0, 0, w, h);
            
            newRendererInView.x = 0;
            newRendererInView.y = 0;
            segmentsChanged = false;
        }
        
        private function drawSegmentPartitions(segments:Vector.<DataGridSegment>):void
        {
            var pt:Point;
            var n:int = segments.length;
            var segment:DataGridSegment;
            var g:Graphics = gfx.graphics;
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                
                if(segment is DataGridSegmentGroup)
                    drawSegmentPartitions(DataGridSegmentGroup(segment).children);
                
                pt = segment.position.clone();
                
                pt.x = isV() ? pt.x - horizontalScrollPosition : headerSize;
                pt.y = isV() ? headerSize : pt.y - verticalScrollPosition;
                
                if((isV() && (pt.x < 0 || pt.x > unscaledWidth)) || (!isV() && (pt.y < 0 || pt.y > unscaledHeight)))
                    continue;
                
                g.moveTo(pt.x, pt.y);
                g.lineTo(isV() ? pt.x : unscaledWidth, isV() ? unscaledHeight : pt.y);
            }
        }
        
        private function positionSegment(segment:DataGridSegment, total:Number):Number
        {
            var p:Point = segment.position.clone();
            p[isV() ? 'x' : 'y'] = total;
            segment.position = p;
            
            if(segment is DataGridSegmentGroup)
            {
                var children:Vector.<DataGridSegment> = DataGridSegmentGroup(segment).children;
                var n:int = children.length;
                for(var i:int = 0; i < n; i++)
                {
                    segment = children[i];
                    total = positionSegment(segment, total);
                }
            }
            else
            {
                total += segment.size;
            }
            
            return total;
        }
    }
}