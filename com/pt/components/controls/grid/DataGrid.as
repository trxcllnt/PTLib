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
            container.segments = segments;
        }
        
        override protected function measure():void
        {
            super.measure();
            
            measuredWidth = explicitWidth || 400;
            measuredHeight = explicitHeight || 250;
        }
    }
}