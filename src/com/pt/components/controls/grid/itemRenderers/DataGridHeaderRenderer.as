package com.pt.components.controls.grid.itemRenderers
{
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.controls.grid.events.HeaderSortEvent;
    import com.pt.components.skins.SaneButtonSkin;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    import mx.controls.Button;
    import mx.core.UIComponent;
    
    public class DataGridHeaderRenderer extends DataGridHeaderBase
    {
        public function DataGridHeaderRenderer()
        {
            super();
            
            setStyle('horizontalAlign', 'center');
            setStyle('verticalAlign', 'top');
            setStyle('skin', SaneButtonSkin);
            
            setStyle('cornerRadius', 0);
            
            setStyle('borderThickness', 0);
            setStyle('selectedBorderThickness', 0);
            
            setStyle('fillColors', [0xFFFFFF, 0xDDDDDD, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0xBBBBBB]);
            setStyle('selectedFillColors', [0xAAAAAA, 0xBBBBBB, 0xCCCCCC, 0xDDDDDD, 0x999999, 0xAAAAAA]);
            
            setStyle('fillAlphas', [1, 1]);
            setStyle('selectedFillAlphas', [1, 1]);
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
        
        public function get selected():Boolean
        {
            return skin.selected;
        }
        
        public function set selected(value:Boolean):void
        {
            skin.selected = value;
        }
        
        private var skin:Button;
        private var headers:UIComponent = new HeaderGroup();
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            if(!skin)
            {
                skin = new Button();
                skin.labelPlacement = 'top';
                skin.setStyle('cornerRadius', 0);
                skin.setStyle('paddingLeft', 0);
                skin.setStyle('paddingRight', 0);
                skin.setStyle('paddingTop', 0);
                skin.setStyle('paddingBottom', 0);
                skin.styleName = this;
                skin.toggle = true;
                skin.addEventListener(Event.CHANGE, onSkinSelectionChange);
            }
            
            if(!$contains(skin))
                $addChild(skin);
            
            $addChild(headers);
        }
        
        private var ascending:Boolean = false;
        
        private function onSkinSelectionChange(event:Event):void
        {
            selected = numChildren == 0;
            
            if(numChildren == 0)
            {
                ascending = !ascending;
                dispatchSortEvent(ascending);
            }
        }
        
        protected function dispatchSortEvent(asc:Boolean):void
        {
            dispatchEvent(new HeaderSortEvent(HeaderSortEvent.SORT, asc));
        }
        
        override protected function commitProperties():void
        {
            if(dataChanged && data is String)
                skin.label = String(data);
            
            super.commitProperties();
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(isV() ? w - 25 : w, isV() ? h : h - 25);
            
            if(numChildren)
            {
                skin.setActualSize(isV() ? 25 : w, isV() ? h : 25);
                headers.move(isV() ? 25 : 0, isV() ? 0 : 25);
            }
            else
            {
                skin.setActualSize(w, h);
            }
        }
        
        override public function contains(child:DisplayObject):Boolean
        {
            return headers.contains(child);
        }
        
        override public function get numChildren():int
        {
            return headers.numChildren;
        }
        
        override public function addChild(child:DisplayObject):DisplayObject
        {
            return headers.addChild(child);
        }
        
        override public function addChildAt(child:DisplayObject, index:int):DisplayObject
        {
            return headers.addChildAt(child, index);
        }
        
        override public function removeChild(child:DisplayObject):DisplayObject
        {
            return headers.removeChild(child);
        }
        
        override public function removeChildAt(index:int):DisplayObject
        {
            return headers.removeChildAt(index);
        }
        
        override public function getChildAt(index:int):DisplayObject
        {
            return headers.getChildAt(index);
        }
        
        override public function getChildByName(name:String):DisplayObject
        {
            return headers.getChildByName(name);
        }
        
        override public function getChildIndex(child:DisplayObject):int
        {
            return headers.getChildIndex(child);
        }
        
        public function $contains(child:DisplayObject):Boolean
        {
            return super.contains(child);
        }
        
        public function get $numChildren():int
        {
            return super.numChildren;
        }
        
        public function $addChild(child:DisplayObject):DisplayObject
        {
            return super.addChild(child);
        }
        
        public function $addChildAt(child:DisplayObject, index:int):DisplayObject
        {
            return super.addChildAt(child, index);
        }
        
        public function $removeChild(child:DisplayObject):DisplayObject
        {
            return super.removeChild(child);
        }
        
        public function $removeChildAt(index:int):DisplayObject
        {
            return super.removeChildAt(index);
        }
        
        public function $getChildAt(index:int):DisplayObject
        {
            return super.getChildAt(index);
        }
        
        public function $getChildByName(name:String):DisplayObject
        {
            return super.getChildByName(name);
        }
        
        public function $getChildIndex(child:DisplayObject):int
        {
            return super.getChildIndex(child);
        }
    }
}
import com.pt.components.containers.layout.ComponentLayout;

import mx.core.UIComponent;

internal class HeaderGroup extends UIComponent
{
    private var layout:ComponentLayout;
    
    public function HeaderGroup(layout:ComponentLayout = null)
    {
        this.layout = layout;
        
        if(layout)
          layout.target = this;
    }
    
    override protected function measure():void
    {
        super.measure();
        
        if(layout)
          layout.measure();
    }
    
    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);
        
        if(layout)
            layout.updateDisplayList(w, h);
    }
}