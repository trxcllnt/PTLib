package com.pt.components.controls.grid
{
    import mx.core.ClassFactory;
    import mx.core.IFactory;
    
    public class DataGridColumn
    {
        public var width:Number = NaN;
        public var measuredWidth:Number = 0;
        
        public var x:Number = 0;
        
        public var rendererField:String;
        
        public var dataField:String;
        public var dataFunction:Function = applyDataField;
        
        private var _header:IFactory;
        
        public function get header():IFactory
        {
            return _header;
        }
        
        public function set header(value:*):void
        {
            if(value === _header)
                return;
            
            if(value is Class)
                value = new ClassFactory(value);
            
            if(!(value is IFactory))
                throw new Error('Must pass in a Class or IFactory instance as an itemRenderer.');
            
            _header = value;
        }
        
        private var _renderer:IFactory;
        
        public function get itemRenderer():IFactory
        {
            return _renderer;
        }
        
        public function set itemRenderer(value:*):void
        {
            if(value === _renderer)
                return;
            
            if(value is Class)
                value = new ClassFactory(value);
            
            if(!(value is IFactory))
                throw new Error('Must pass in a Class or IFactory instance as an itemRenderer.');
            
            _renderer = value;
        }
        
        private function applyDataField(data:*):String
        {
            if(dataField in data)
                return data[dataField].toString();
            
            return "";
        }
    }
}