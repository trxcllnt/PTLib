package com.pt.components.containers
{
    import com.pt.components.containers.layout.ArrayChildList;
    import com.pt.components.containers.layout.VirtualBoxLayout;
    import com.pt.components.containers.layout.VirtualCanvasLayout;
    import com.pt.components.containers.layout.layout;
    import com.pt.components.containers.layout.union;
    import com.pt.virtual.Virtual;
    
    import flash.display.DisplayObject;
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
            var children:Array = _virtual.getItems("x").concat(_virtual.getItems("y"));
            
            if(children.indexOf(child) == -1)
                measureLayout = true;
            
            return super.addChildAt(child, index);
        }
        
        override public function removeChild(child:DisplayObject):DisplayObject
        {
            measureLayout = true;
            
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
            super.createChildren();
            
            if(!_virtual)
                _virtual = new Virtual('x', 'y');
        }
        
        override protected function measure():void
        {
            if(measureLayout)
                super.measure();
        }
        
        protected var _virtual:Virtual;
        
        layout function get virtual():Virtual
        {
            return _virtual;
        }
        
        layout var measureLayout:Boolean = true;
        private var scrollBounds:Rectangle;
        
        override mx_internal function getScrollableRect():Rectangle
        {
            if(scrollBounds && !measureLayout)
                return scrollBounds;
            
            var left:Number = 0;
            var top:Number = 0;
            var right:Number = 0;
            var bottom:Number = 0;
            var x:Number;
            var y:Number;
            var width:Number;
            var height:Number;
            var child:DisplayObject;
            var uic:IUIComponent;
            
            var xChildren:Array = _virtual.getItems("x");
            var yChildren:Array = _virtual.getItems("y");
            
            var children:Array = union(xChildren, yChildren);
            var childList:IChildList = new ArrayChildList(children.length ? children : getChildren());
            var n:int = childList.numChildren;
            
            for(var i:int = 0; i < n; i++)
            {
                child = childList.getChildAt(i);
                if(child is IUIComponent)
                {
                    if(!IUIComponent(child).includeInLayout)
                        continue;
                    uic = PostScaleAdapter.getCompatibleIUIComponent(child);
                    width = uic.getExplicitOrMeasuredWidth();
                    height = uic.getExplicitOrMeasuredHeight();
                    x = uic.x;
                    y = uic.y;
                }
                else
                {
                    width = child.width;
                    height = child.height;
                    x = child.x;
                    y = child.y;
                }
                
                left = Math.min(left, x);
                top = Math.min(top, y);
                
                // width/height can be NaN if using percentages and
                // hasn't been layed out yet.
                if(!isNaN(width))
                    right = Math.max(right, x + width);
                if(!isNaN(height))
                    bottom = Math.max(bottom, y + height);
            }
            
            // Add in the right/bottom margins and view metrics.
            var vm:EdgeMetrics = viewMetrics;
            
            var bounds:Rectangle = new Rectangle();
            bounds.left = left;
            bounds.top = top;
            bounds.right = right;
            bounds.bottom = bottom;
            
            if(usePadding)
            {
                bounds.right += getStyle("paddingRight");
                bounds.bottom += getStyle("paddingBottom");
            }
            
            scrollBounds = bounds;
            
            return bounds;
        }
        
        override protected function scrollChildren():void
        {
            if(!contentPane)
                return;
            
            if(showMask)
                super.scrollChildren();
            else
                contentPane.scrollRect = null;
//            if(!contentPane)
//                return;
//            
//            contentPane.scrollRect = showMask ? new Rectangle(0, 0, unscaledWidth, unscaledHeight) : null;
        }
    }
}
