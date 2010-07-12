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
        
        public function get headerSize():Number
        {
            if(header)
                return isV() ? header.getExplicitOrMeasuredHeight() : header.getExplicitOrMeasuredWidth();
            
            return 0;
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
            {
                header.segments = segments;
                if(list)
                    list.segments = header.computedSegments;
            }
            
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
            list.segments = header.computedSegments;
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
            var maxPosition:Number = minPosition + (isV() ? unscaledWidth : unscaledHeight);
            var items:Array = segmentDimension.getBetween(minPosition, maxPosition);
            
            visibleSegments = Vector.<DataGridSegment>(items);
            header.segments = visibleSegments;
            list.segments = header.computedSegments;
            
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
                    
                    if(isNaN(segment.size))
                        segment.size = segment.measuredSize;
                    
                    segmentDimension.add(segment, segment.size);
                }
                
                if(isV())
                {
                    measuredWidth = segmentDimension.size;
                    measuredHeight = list.getExplicitOrMeasuredHeight();
                }
                else
                {
                    measuredWidth = list.getExplicitOrMeasuredWidth();
                    measuredHeight = segmentDimension.size;
                }
                
                processSegments();
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
            
            var segment:DataGridSegment;
            var i:int;
            if(segmentsChanged)
            {
                var n:int = segments.length;
                var c:Number = 0;
                
                for(i = 0; i < n; i++)
                {
                    segment = segments[i];
                    segment.position[isV() ? 'x' : 'y'] = c;
                    c += segment.size;
                }
            }
            
            if(visibleSegments.length)
            {
                g = gfx.graphics;
                g.clear();
                g.lineStyle(1, 0xCCCCCC);
                
                var pt:Point;
                n = visibleSegments.length;
                
                for(i = 0; i < n; i++)
                {
                    segment = visibleSegments[i];
                    pt = segment.position.clone();
                    
                    pt.x = isV() ? pt.x - horizontalScrollPosition : 0;
                    pt.y = isV() ? 0 : pt.y - verticalScrollPosition;
                    
                    if((isV() && (pt.x < 0 || pt.x > w)) || (!isV() && (pt.y < 0 || pt.y > h)))
                        continue;
                    
                    g.moveTo(pt.x, pt.y);
                    g.lineTo(isV() ? pt.x : w , isV() ? h : pt.y);
                }
                
                var scrollIndex:int = isV() ? 1 : 0;
                segment = visibleSegments[0];
                scrollDelta[scrollIndex].x = segmentDimension.getPosition(segment);
                segment = visibleSegments[visibleSegments.length - 1];
                scrollDelta[scrollIndex].y = segmentDimension.getPosition(segment) + segmentDimension.getSize(segment);
            }
            
            if(isV())
            {
                header.setActualSize(w, header.getExplicitOrMeasuredHeight());
                list.setActualSize(w, h - header.height);
                list.move(0, header.height);
            }
            else
            {
                header.setActualSize(header.getExplicitOrMeasuredWidth(), h);
                list.setActualSize(w - header.width, h);
                list.move(header.width, 0);
            }
            
            newRendererInView.x = 0;
            newRendererInView.y = 0;
            segmentsChanged = false;
        }
    }
}