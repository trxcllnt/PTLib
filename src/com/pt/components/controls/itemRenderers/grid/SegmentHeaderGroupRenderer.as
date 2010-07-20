package com.pt.components.controls.itemRenderers.grid
{
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.containers.layout.HLayout;
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.controls.grid.events.HeaderSortEvent;
    
    import flash.display.DisplayObject;
    
    import mx.core.UIComponent;
    
    public class SegmentHeaderGroupRenderer extends SegmentHeaderRenderer
    {
        public function SegmentHeaderGroupRenderer()
        {
            super();
        }
        
        private var headers:UIComponent = new HeaderGroup(new HLayout());
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            super.addChild(headers);
            
            headers.setStyle('horizontalAlign', 'bottom');
            headers.setStyle('horizontalGap', 0);
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            if(numChildren)
            {
                tf.y = 2;
                segment.resizable = false;
                handle.mouseEnabled = false;
            }
            
            headers.setActualSize(w, h - tf.height - 4);
            
            headers.move(0, h - headers.height);
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
        
        protected var parentDataFields:Array;
        override protected function dispatchSortEvent(asc:Boolean):void
        {
          parentDataFields = [];
          var s:DataGridSegment = segment;
          while(s)
          {
            parentDataFields.unshift(s.dataField);
            s = s.parent;
          }
          
          dispatchEvent(new HeaderSortEvent(HeaderSortEvent.SORT, asc));
        }
    }
}
import com.pt.components.containers.layout.ComponentLayout;
import com.pt.components.containers.layout.HLayout;

import flash.display.Graphics;

import mx.core.UIComponent;

internal class HeaderGroup extends UIComponent
{
    private var layout:ComponentLayout;
    
    public function HeaderGroup(layout:ComponentLayout)
    {
        this.layout = layout;
        this.layout.target = this;
    }
    
    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);
        
        if(layout)
            layout.updateDisplayList(w, h);
    }
}