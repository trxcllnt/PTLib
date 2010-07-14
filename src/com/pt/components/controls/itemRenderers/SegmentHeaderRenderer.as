package com.pt.components.controls.itemRenderers
{
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.skins.SaneButtonSkin;
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.events.EventPhase;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import mx.controls.Button;
    import mx.core.IDataRenderer;
    import mx.core.IFlexDisplayObject;
    import mx.core.IInvalidating;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;
    import mx.styles.ISimpleStyleClient;
    
    public class SegmentHeaderRenderer extends UIComponent implements IDataRenderer
    {
        public function SegmentHeaderRenderer()
        {
            super();
            
            setStyle('cornerRadius', 0);
            
            setStyle('borderColors', [0x00, 0x00]);
            setStyle('borderThickness', 1);
            
            setStyle('selectedBorderColors', [0x00, 0x00]);
            setStyle('selectedBorderThickness', 1);
            
            setStyle('fillColors', [0xCCCCCC, 0xDDDDDD, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0xBBBBBB]);
            setStyle('selectedFillColors', [0xAAAAAA, 0xBBBBBB, 0xCCCCCC, 0xDDDDDD, 0x999999, 0xAAAAAA]);
            
            setStyle('fillAlphas', [0.25, 0.25]);
            setStyle('selectedFillAlphas', [0.25, 0.25]);
            
            percentWidth = 100;
            percentHeight = 100;
            
            addEventListener(MouseEvent.CLICK, onClick);
            addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }
        
        private var changeSkin:Boolean = false;
        private var over:Boolean = false;
        
        private function onMouseOver(event:MouseEvent):void
        {
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            over = true;
            changeSkin = true;
            invalidateDisplayList();
        }
        
        private function onMouseOut(event:MouseEvent):void
        {
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            over = false;
            changeSkin = true;
            invalidateDisplayList();
        }
        
        private var down:Boolean = false;
        
        private function onDown(event:MouseEvent):void
        {
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            down = true;
            changeSkin = true;
            invalidateDisplayList();
        }
        
        private function onClick(event:MouseEvent):void
        {
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            down = false;
            selected = !selected;
        }
        
        private var _data:Object;
        
        public function get data():Object
        {
            return _data;
        }
        
        public function set data(value:Object):void
        {
            if(value === _data)
                return;
            
            _data = value;
            
            if(data && tf)
                tf.text = data.toString();
            
            invalidateDisplayList();
        }
        
        private var _segment:DataGridSegment;
        public function get segment():DataGridSegment
        {
            return _segment;
        }
        
        public function set segment(value:DataGridSegment):void
        {
            if(value === _segment)
                return;
            
            _segment = value;
            selected = segment.selected;
        }
        
        private var _selected:Boolean = false;
        
        public function get selected():Boolean
        {
            return _selected;
        }
        
        public function set selected(value:Boolean):void
        {
            if(value == _selected)
                return;
            
            if(segment)
                segment.selected = value;
            
            changeSkin = true;
            _selected = value;
            invalidateDisplayList();
        }
        
        protected var tf:TextField;
        protected var skin:IFlexDisplayObject;
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            if(!tf)
            {
                tf = new TextField();
                tf.defaultTextFormat = new TextFormat(null, 14);
                tf.autoSize = TextFieldAutoSize.LEFT;
                tf.selectable = false;
                tf.mouseEnabled = false;
                
                super.addChildAt(tf, 0);
            }
            
            if(!skin)
            {
                skin = new SaneButtonSkin();
                if(skin is ISimpleStyleClient)
                    ISimpleStyleClient(skin).styleName = this;
                
                super.addChildAt(DisplayObject(skin), super.getChildIndex(tf));
            }
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            skin.setActualSize(w, h);
            
            if(changeSkin)
            {
                skin.name = selected ? (down ? "selectedDownSkin" : (over ? "selectedOverSkin" : "selectedUpSkin")) :
                    (down ? "downSkin" : (over ? "overSkin" : "upSkin"));
                
                if(skin is IInvalidating)
                {
                    IInvalidating(skin).invalidateDisplayList();
                    IInvalidating(skin).validateNow();
                }
            }
            
            changeSkin = false;
            
            tf.y = (h - tf.height) * .5;
            tf.x = (w - tf.width) * .5;
        }
    }
}