package com.pt.components.controls.itemRenderers
{
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.containers.layout.HLayout;
    
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    
    import mx.core.IDataRenderer;
    import mx.core.UIComponent;
    
    public class SegmentHeaderRenderer extends UIComponent implements IDataRenderer
    {
        public function SegmentHeaderRenderer()
        {
            super();
            
            setStyle('horizontalAlign', 'center');
            
            layout = new HLayout();
            layout.target = this;
        }
        
        protected var layout:ComponentLayout;
        
        private var _data:Object;
        private var dataChanged:Boolean = false;
        
        public function get data():Object
        {
            return _data;
        }
        
        public function set data(value:Object):void
        {
            if(value === _data)
                return;
            
            _data = value;
            dataChanged = true;
            invalidateProperties();
        }
        
        private var label:TextField;
        
        override protected function createChildren():void
        {
            super.createChildren();
            label = new TextField();
            label.autoSize = TextFieldAutoSize.LEFT;
            
            addChild(label);
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(dataChanged)
                setData(data);
            dataChanged = false;
        }
        
        protected function setData(data:Object):void
        {
            label.text = data.toString();
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            layout.updateDisplayList(w, h);
        }
    }
}