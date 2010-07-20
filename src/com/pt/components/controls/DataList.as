package com.pt.components.controls
{
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.containers.layout.ListLayout;
    import com.pt.virtual.Dimension;
    import com.pt.virtual.Virtual;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.containers.BoxDirection;
    import mx.core.ClassFactory;
    import mx.core.IDataRenderer;
    import mx.core.IFactory;
    import mx.core.IInvalidating;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;
    import mx.styles.ISimpleStyleClient;
    
    [Style(name="itemRendererStyleName", type="String")]
    
    public class DataList extends UIComponent
    {
        public function DataList()
        {
            super();
            layout = new ListLayout();
            layout.target = this;
        }
        
        protected function isV():Boolean
        {
            return direction == BoxDirection.VERTICAL;
        }
        
        protected var layout:ComponentLayout;
        
        private var _direction:String = BoxDirection.VERTICAL;
        protected var directionChanged:Boolean = false;
        
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
            directionChanged = true;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        public function getDimension(direction:String):Dimension
        {
            if(direction == BoxDirection.VERTICAL)
                return virtual.getDimension('x');
            
            return virtual.getDimension('y');
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
        }
        
        private var _variableItemSize:Boolean = true;
        
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
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        private var _horizontalScrollPosition:Number = -1;
        
        public function get horizontalScrollPosition():Number
        {
            return _horizontalScrollPosition;
        }
        
        public function set horizontalScrollPosition(value:Number):void
        {
            if(value === _horizontalScrollPosition)
                return;
            
            newRendererInView.x = int((value < _horizontalScrollPosition) ?
                value <= scrollDelta[1].x :
                value + width >= scrollDelta[1].y);
            
            _horizontalScrollPosition = value;
            
            setScrollRect();
            
            if(newRendererInView.x)
            {
                lastRendererScrollPosition.x = value;
                commitRendererData();
            }
            
            invalidateDisplayList();
        }
        
        private var _verticalScrollPosition:Number = -1;
        
        public function get verticalScrollPosition():Number
        {
            return _verticalScrollPosition;
        }
        
        public function set verticalScrollPosition(value:Number):void
        {
            if(value === _verticalScrollPosition)
                return;
            
            newRendererInView.y = int((value < _verticalScrollPosition) ?
                value <= scrollDelta[0].x :
                value + height >= scrollDelta[0].y);
            
            _verticalScrollPosition = value;
            
            setScrollRect();
            
            if(newRendererInView.y)
            {
                lastRendererScrollPosition.y = value;
                commitRendererData();
            }
            
            invalidateDisplayList();
        }
        
        protected var dataProviderChanged:Boolean = false;
        
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
            dataProviderChanged = true;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        protected var itemRendererChanged:Boolean = false;
        protected var itemRendererFactory:IFactory;
        
        protected var renderers:Array;
        
        public function set itemRenderer(factory:IFactory):void
        {
            if(factory == itemRendererFactory)
                return;
            
            itemRendererFactory = factory;
            itemRendererChanged = true;
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        public function sort(sortFunc:Function, ...sortOptions):void
        {
        }
        
        protected var virtual:Virtual;
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            renderers = [];
            
            if(!virtual)
                virtual = new Virtual("x", "y");
        }
        
        protected function commitRendererData():void
        {
            if(!processRendererData() || !scrollRect)
                return;
            
            var minPosition:Number = isV() ? scrollRect.y : scrollRect.x;
            var maxPosition:Number = minPosition + (isV() ? scrollRect.height : scrollRect.width);
            
            var d:Dimension = getDimension(direction);
            var items:Array = d.getBetween(minPosition, maxPosition);
            var n:int = items.length;
            var renderer:DisplayObject;
            
            for(var i:int = 0; i < n; i++)
            {
                if(i in renderers)
                    renderer = renderers[i];
                else
                {
                    renderers.push(renderer = itemRendererFactory.newInstance());
                    if(renderer is ISimpleStyleClient)
                        ISimpleStyleClient(renderer).styleName = getStyle("itemRendererStyleName");
                    addChild(renderer as DisplayObject);
                }
                
                setRendererData(renderer, items[i], d.getIndex(items[i]));
            }
            
            while(renderers.length > n)
            {
                removeChild(renderers.splice(renderers.length - 1, 1)[0]);
            }
        }
        
        protected function processRendererData():Boolean
        {
            var newRenderer:Boolean = isV() ? Boolean(newRendererInView.y) : Boolean(newRendererInView.x);
            return (dataProviderChanged || itemRendererChanged || newRenderer || directionChanged);
        }
        
        override protected function measure():void
        {
            if(dataProviderChanged || (dataProvider && (itemRendererChanged || directionChanged)))
            {
                // Only do this when the data or itemRenderer changes. This is an incredibly
                // intensive operation, so change the data/renderers as little as possible.
                layout.measure();
                measureAllDataItems();
                commitRendererData();
            }
        }
        
        protected var scrollDelta:Vector.<Point> = new <Point>[new Point(), new Point()];
        protected var lastRendererScrollPosition:Point = new Point(-10000, -10000);
        protected var newRendererInView:Point = new Point();
        
        protected function setRendererData(renderer:DisplayObject, data:Object, index:int):void
        {
            if(!('data' in renderer))
                return;
            
            renderer['data'] = data;
        }
        
        protected function setScrollRect():void
        {
            scrollRect = new Rectangle(horizontalScrollPosition, verticalScrollPosition, unscaledWidth, unscaledHeight);
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            setScrollRect();
            
            layout.updateDisplayList(w, h);
            
            if(renderers.length > 0)
            {
                var item:Object = renderers[0]['data'];
                var scrollIndex:int = isV() ? 0 : 1;
                scrollDelta[scrollIndex].x = getDimension(direction).getPosition(item);
                item = renderers[renderers.length - 1]['data'];
                scrollDelta[scrollIndex].y = getDimension(direction).getPosition(item) + getDimension(direction).getSize(item);
            }
            
            newRendererInView.x = 0;
            newRendererInView.y = 0;
            itemRendererChanged = false;
            dataProviderChanged = false;
            directionChanged = false;
        }
        
        protected function measureAllDataItems():void
        {
            if(!itemRendererFactory)
                return;
            
            getDimension(direction).clear();
            
            measuredWidth = 0;
            measuredHeight = 0;
            
            var renderer:DisplayObject = itemRendererFactory.newInstance();
            
            if(renderer is ISimpleStyleClient)
                ISimpleStyleClient(renderer).styleName = getStyle("itemRendererStyleName");
            
            addChild(renderer);
            
            // Assume data is an Array, TODO: Update this to work with any collection.
            var a:Array = dataProvider as Array;
            var i:int = 0;
            var n:int = a.length;
            var rSize:Point = new Point();
            
            // measure all the rows
            if(variableItemSize)
            {
                for(i = 0; i < n; i++)
                {
                    setRendererData(renderer, a[i], i);
                    
                    if(renderer is IInvalidating)
                        IInvalidating(renderer).validateNow();
                    
                    rSize = getRendererSize(renderer);
                    
                    enqueueDataItem(renderer, a[i]);
                    measuredWidth = isV() ? Math.max(rSize.x, measuredWidth) : measuredWidth + rSize.x;
                    measuredHeight = isV() ? measuredHeight + rSize.y : Math.max(rSize.y, measuredHeight);
                }
            }
            else
            {
                setRendererData(renderer, a[0], 0);
                
                if(isV())
                    renderer.height = itemSize;
                else
                    renderer.width = itemSize;
                
                if(renderer is IInvalidating)
                    IInvalidating(renderer).validateNow();
                
                rSize = getRendererSize(renderer);
                measuredWidth = isV() ? Math.max(rSize.x, measuredWidth) : (Math.max(itemSize, 0) * n);
                measuredHeight = isV() ? (Math.max(itemSize, 0) * n) : Math.max(rSize.y, measuredHeight);
                for(i = 0; i < n; i++)
                {
                    enqueueDataItem(renderer, a[i]);
                }
            }
            
            if(renderer is ISimpleStyleClient)
                ISimpleStyleClient(renderer).styleName = null;
            
            if(renderer is IDataRenderer)
                IDataRenderer(renderer).data = null;
            
            removeChild(renderer);
            
            renderer = null;
        }
        
        protected function getRendererSize(renderer:DisplayObject):Point
        {
            var p:Point = new Point();
            if(renderer is IUIComponent)
            {
                p.x = IUIComponent(renderer).getExplicitOrMeasuredWidth();
                p.y = IUIComponent(renderer).getExplicitOrMeasuredHeight();
            }
            else
            {
                p.x = renderer.width;
                p.y = renderer.height;
            }
            return p;
        }
        
        protected function enqueueDataItem(renderer:DisplayObject, data:Object):void
        {
            var num:Number;
            
            if(direction == 'vertical')
            {
                num = renderer is IUIComponent ?
                    IUIComponent(renderer).getExplicitOrMeasuredHeight() :
                    renderer.height;
            }
            else if(direction == 'horizontal')
            {
                num = renderer is IUIComponent ?
                    IUIComponent(renderer).getExplicitOrMeasuredWidth() :
                    renderer.width;
            }
            
            getDimension(direction).add(data, num);
        }
    }
}