package com.pt.components.containers.layout
{
    import flash.display.Sprite;
    
    import mx.core.IInvalidating;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;
    import mx.styles.IStyleClient;

    public class ComponentLayout
    {
        public function ComponentLayout()
        {
        }
        
        private var _target:Sprite;
        
        public function get target():Sprite
        {
            return _target;
        }
        
        public function set target(value:Sprite):void
        {
            if(value === _target)
                return;
            
            _target = value;
            if(target is IInvalidating)
            {
                IInvalidating(target).invalidateSize();
                IInvalidating(target).invalidateDisplayList();
            }
        }
        
        public function measure():void
        {
        }
        
        public function updateDisplayList(w:Number, h:Number):void
        {
        }
        
        protected function getHorizontalAlignValue():Number
        {
            if(!(target is IStyleClient))
                return 0;
            
            var horizontalAlign:String = IStyleClient(target).getStyle("horizontalAlign");
            
            if (horizontalAlign == "center")
                return 0.5;
                
            else if (horizontalAlign == "right")
                return 1;
            
            // default = left
            return 0;
        }
        
        protected function getVerticalAlignValue():Number
        {
            if(!(target is IStyleClient))
                return 0;
            
            var verticalAlign:String = IStyleClient(target).getStyle("verticalAlign");
            
            if (verticalAlign == "middle")
                return 0.5;
                
            else if (verticalAlign == "bottom")
                return 1;
            
            // default = top
            return 0;
        }
    }
}