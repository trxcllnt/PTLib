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
        public var dataFunction:Function = applyDataField;
        
        public var title:String;
        
        private var _header:ClassFactory;
        
        public function get header():ClassFactory
        {
            return _header;
        }
        
        public function set header(value:*):void
        {
            if(value === _header)
                return;
            
            if(value is IFactory && !(value is ClassFactory))
                value = IFactory(value).newInstance()['constructor'];
            
            if(value is Class)
                value = new ClassFactory(value);
            
            if(!(value is ClassFactory))
                throw new Error('Must pass in a Class or IFactory instance as a header renderer.');
            
            _header = ClassFactory(value);
        }
        
        private var item:ClassFactory;
        
        public function get renderer():ClassFactory
        {
            return item;
        }
        
        public function set renderer(value:*):void
        {
            if(value === item)
                return;
            
            if(value is IFactory && !(value is ClassFactory))
                value = IFactory(value).newInstance()['constructor'];
            
            if(value is Class)
                value = new ClassFactory(value);
            
            if(!(value is ClassFactory))
                throw new Error('Must pass in a Class or IFactory instance as an itemRenderer.');
            
            item = ClassFactory(value);
        }
        
        private function applyDataField(data:*):String
        {
            if(dataField in data)
                return data[dataField].toString();
            
            return "";
        }
    }
}