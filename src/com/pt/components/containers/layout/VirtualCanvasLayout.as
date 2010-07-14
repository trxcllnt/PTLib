package com.pt.components.containers.layout
{
    import com.pt.components.containers.VirtualContainer;
    
    import mx.containers.utilityClasses.CanvasLayout;
    
    use namespace layout;
    
    public class VirtualCanvasLayout extends CanvasLayout
    {
        public function VirtualCanvasLayout()
        {
            super();
        }
        
        override public function measure():void
        {
            if(!virtualContainer.measureLayout)
                super.measure();
        }
        
        override public function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            virtualContainer.measureLayout = false;
        }
        
        protected function get virtualContainer():VirtualContainer
        {
            return target as VirtualContainer;
        }
    }
}