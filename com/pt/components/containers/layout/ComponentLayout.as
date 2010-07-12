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
        
        protected function getHorizontalAlignValue():Number
        {
            var horizontalAlign:String = target.getStyle("horizontalAlign");
            
            if (horizontalAlign == "center")
                return 0.5;
                
            else if (horizontalAlign == "right")
                return 1;
            
            // default = left
            return 0;
        }
        
        protected function getVerticalAlignValue():Number
        {
            var verticalAlign:String = target.getStyle("verticalAlign");
            
            if (verticalAlign == "middle")
                return 0.5;
                
            else if (verticalAlign == "bottom")
                return 1;
            
            // default = top
            return 0;
        }
    }
}