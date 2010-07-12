package com.pt.components.containers.layout
{
    import com.pt.components.containers.VirtualContainer;
    import com.pt.virtual.Virtual;
    
    import flash.display.DisplayObject;
    
    import mx.containers.BoxDirection;
    import mx.containers.utilityClasses.BoxLayout;
    import mx.core.IChildList;
    import mx.core.mx_internal;
    
    use namespace layout;
    use namespace mx_internal;
    
    public class VirtualBoxLayout extends BoxLayout
    {
        public function VirtualBoxLayout()
        {
            super();
        }
        
        override public function measure():void
        {
            if(virtualContainer.measureLayout)
                super.measure();
        }
        
        override public function updateDisplayList(w:Number, h:Number):void
        {
            var virtual:Virtual = virtualContainer.virtual;
            
            if(virtualContainer.measureLayout)
            {
                if(virtual.hasDimension("x"))
                    virtual.getDimension("x").clear();
                if(virtual.hasDimension("y"))
                    virtual.getDimension("y").clear();
            }
            
            var hPos:Number = target.horizontalScrollPosition;
            var vPos:Number = target.verticalScrollPosition;
            
            var children:Array = isVertical() ? virtual.getItemsAt(vPos, vPos + h, "y") : virtual.getItemsAt(hPos, hPos + w, "x");
            var childList:IChildList = new ArrayChildList(children.length ? children : target.getChildren());
            
            var i:int = 0;
            var n:int = childList.numChildren;
            var targetChildren:Array = target.getChildren();
            var obj:DisplayObject;
            var temp:int = 0;
            
            for(i = 0; i < n; i++)
            {
                obj = childList.getChildAt(i);
                
                temp = targetChildren.indexOf(obj);
                if(temp == -1)
                {
                    target.addChildAt(obj, i);
                    continue;
                }
                
                targetChildren.splice(temp, 1);
            }
            
            var _m:Boolean = virtualContainer.measureLayout;
            
            while(targetChildren.length)
            {
                target.removeChild(targetChildren.pop());
            }
            
            virtualContainer.measureLayout = _m;
            
            var layout:ComponentLayout = isVertical() ? new VLayout() : new HLayout();
            layout.target = target;
            layout.updateDisplayList(w, h);
            
            n = childList.numChildren;
            var itemOffset:Number = 0;
            for(i = 0; i < n; i++)
            {
                obj = childList.getChildAt(i);
                
                if(virtualContainer.measureLayout)
                {
                    if(isVertical())
                        virtual.addAt(obj, obj.y, obj.height, "y");
                    else
                        virtual.addAt(obj, obj.x, obj.width, "x");
                }
                if(i == 0)
                {
                    itemOffset = virtual.getItemPosition(obj, isVertical() ? "y" : "x");
                }
                
                obj[isVertical() ? "y" : "x"] += itemOffset;
            }
            
            virtualContainer.measureLayout = false;
        }
        
        protected function get virtualContainer():VirtualContainer
        {
            return target as VirtualContainer;
        }
        
        protected function isVertical():Boolean
        {
            return direction != BoxDirection.HORIZONTAL;
        }
    }
}