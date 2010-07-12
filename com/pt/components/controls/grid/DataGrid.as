package com.pt.components.controls.grid
{
    import com.pt.components.controls.Scroller;
    
    import flash.display.DisplayObject;
    
    import mx.containers.BoxDirection;
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
            
            if(container)
                container.direction = direction;
            
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
        
        protected var container:DataGridContainer;
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            container = new DataGridContainer();
            target = container;
            
            container.direction = direction;
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
    }
}