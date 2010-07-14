package com.pt.components.controls.grid
{
    import flash.geom.Point;
    
    import mx.core.ClassFactory;
    import mx.core.IFactory;
    
    public class DataGridSegment
    {
        public var size:Number = NaN;
        public var measuredSize:Number = 0;
        
        public var selected:Boolean = false;
        
        public function getRelativePosition():Point
        {
            var pt:Point = position.clone();
            if(parent)
            {
                pt.x -= parent.position.x;
                pt.y -= parent.position.y;
            }
            
            return pt;
        }
        
        protected var pos:Point = new Point();
        
        public function get position():Point
        {
            return pos;
        }
        
        public function set position(value:Point):void
        {
            if(value === pos)
                return;
            
            pos = value;
        }
        
        protected var _parent:DataGridSegmentGroup;
        
        public var parent:DataGridSegmentGroup;
        
        public var rendererField:String;
        public var headerField:String;
        
        public var dataField:String;
        public var dataFunction:Function;
        
        public var sortField:String;
        public var sortFunction:Function;
        
        public var title:String;
        
        private var _header:IFactory;
        
        public function get header():IFactory
        {
            return _header;
        }
        
        public function set header(factory:IFactory):void
        {
            if(factory === _header)
                return;
            
            _header = factory;
        }
        
        private var item:IFactory;
        
        public function get renderer():IFactory
        {
            return item;
        }
        
        public function set renderer(factory:IFactory):void
        {
            if(factory === item)
                return;
            
            item = factory;
        }
        
        public function applyData(data:*):*
        {
            if(dataFunction != null)
                return dataFunction(data);
            
            if(data && dataField in data)
                return data[dataField];
            
            return "";
        }
    }
}