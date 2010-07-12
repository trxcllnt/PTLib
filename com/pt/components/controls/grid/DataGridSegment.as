package com.pt.components.controls.grid
{
    import flash.geom.Point;
    
    import mx.core.ClassFactory;
    import mx.core.IFactory;
    
    public class DataGridSegment
    {
        public var size:Number = NaN;
        public var measuredSize:Number = 0;
        
        public var position:Point = new Point();
        
        public var rendererField:String;
        public var headerField:String;
        
        public var dataField:String;
        public var dataFunction:Function;
        
        public var title:String;
        
        public var children:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
        
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
        
        public function applyData(data:*):String
        {
            if(dataFunction != null)
                return dataFunction(data);
            
            if(dataField in data)
                return data[dataField].toString();
            
            return "";
        }
    }
}