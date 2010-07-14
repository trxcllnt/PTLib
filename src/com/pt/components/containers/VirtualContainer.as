package com.pt.components.containers
{
    import com.pt.components.containers.layout.ArrayChildList;
    import com.pt.components.containers.layout.VirtualBoxLayout;
    import com.pt.components.containers.layout.VirtualCanvasLayout;
    import com.pt.components.containers.layout.layout;
    import com.pt.components.containers.layout.union;
    import com.pt.virtual.Dimension;
    import com.pt.virtual.Virtual;
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.containers.utilityClasses.BoxLayout;
    import mx.containers.utilityClasses.CanvasLayout;
    import mx.containers.utilityClasses.Layout;
    import mx.containers.utilityClasses.PostScaleAdapter;
    import mx.core.EdgeMetrics;
    import mx.core.IChildList;
    import mx.core.IRectangularBorder;
    import mx.core.IUIComponent;
    import mx.core.mx_internal;
    
    use namespace layout;
    use namespace mx_internal;
    
    public class VirtualContainer extends LayoutContainer
    {
        public function VirtualContainer()
        {
            super();
        }
        
        override public function addChildAt(child:DisplayObject, index:int):DisplayObject
        {
            var children:Array = v.getItems("x").concat(v.getItems("y"));
            
            if(children.indexOf(child) == -1)
            {
                measureLayout = true;
                scrollBounds = null;
            }
            
            invalidateSize();
            invalidateDisplayList();
            
            return super.addChildAt(child, index);
        }
        
        override public function removeChild(child:DisplayObject):DisplayObject
        {
            measureLayout = true;
            scrollBounds = null;
            
            invalidateSize();
            invalidateDisplayList();
            
            return super.removeChild(child);
        }
        
        private var _showMask:Boolean = true;
        
        public function get showMask():Boolean
        {
            return _showMask;
        }
        
        public function set showMask(value:Boolean):void
        {
            if(value === _showMask)
                return;
            
            _showMask = value;
            scrollChildren();
        }
        
        private var _showDebug:Boolean = false;
        
        public function get showDebug():Boolean
        {
            return _showDebug;
        }
        
        public function set showDebug(value:Boolean):void
        {
            if(value === _showDebug)
                return;
            
            _showDebug = value;
            scrollChildren();
        }
        
        override protected function setLayout(value:*):Layout
        {
            value = super.setLayout(value);
            
            if(value is BoxLayout)
            {
                value = new VirtualBoxLayout();
                value.direction = layoutObject['direction'];
            }
            else if(value is CanvasLayout)
                value = new VirtualCanvasLayout();
            
            layoutObject = value;
            
            return layoutObject;
        }
        
        override protected function createChildren():void
        {
            if(!v)
                v = new Virtual('x', 'y');
            
            super.createChildren();
        }
        
        override protected function measure():void
        {
            if(measureLayout)
                super.measure();
        }
        
        protected var v:Virtual;
        
        layout function get virtual():Virtual
        {
            return v;
        }
        
        layout var measureLayout:Boolean = true;
        private var scrollBounds:Rectangle;
        
        override mx_internal function getScrollableRect():Rectangle
        {
            if(scrollBounds && !measureLayout)
                return scrollBounds;
            
            scrollBounds = new Rectangle(0, 0, v.getSize("x"), v.getSize("y"));;
            
            return scrollBounds;
        }
        
        override protected function scrollChildren():void
        {
            if(!contentPane)
                return;
            
            if(showMask)
                super.scrollChildren();
            else
                contentPane.scrollRect = null;
            
            var g:Graphics = graphics;
            g.clear();
            
            if(showDebug)
            {
                g.lineStyle(2, 0x0, 0.75);
                g.drawRect(horizontalScrollPosition, verticalScrollPosition, unscaledWidth, unscaledHeight);
            }
            else if(!showMask)
            {
                var n:int = numChildren;
                var child:DisplayObject;
                
                for(var i:int = 0; i < n; i++)
                {
                    child = getChildAt(i);
                    if(child is IUIComponent)
                    {
                        IUIComponent(child).move(child.x - horizontalScrollPosition, child.y - verticalScrollPosition);
                    }
                    else
                    {
                        child.x -= horizontalScrollPosition;
                        child.y -= verticalScrollPosition;
                    }
                }
            }
        }
    }
}
