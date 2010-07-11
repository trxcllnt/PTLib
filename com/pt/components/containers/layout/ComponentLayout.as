package com.pt.components.containers.layout
{
    import mx.core.UIComponent;

    public class ComponentLayout
    {
        public function ComponentLayout()
        {
        }
        
        private var _target:UIComponent;
        
        public function get target():UIComponent
        {
            return _target;
        }
        
        public function set target(value:UIComponent):void
        {
            if(value === _target)
                return;
            
            _target = value;
            target.invalidateSize();
            target.invalidateDisplayList();
        }
        
        public function measure():void
        {
        }
        
        public function updateDisplayList(w:Number, h:Number):void
        {
        }
    }
}