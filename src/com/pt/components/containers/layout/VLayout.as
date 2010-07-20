package com.pt.components.containers.layout
{
    import flash.display.DisplayObject;
    
    import mx.core.IChildList;
    import mx.core.IUIComponent;
    import mx.styles.IStyleClient;
    
    public class VLayout extends ComponentLayout
    {
        
        override public function measure():void
        {
            var minWidth:Number = 0;
            var minHeight:Number = 0;
            
            var preferredWidth:Number = 0;
            var preferredHeight:Number = 0;
            
            var n:int = target.numChildren;
            var numChildrenWithOwnSpace:int = n;
            var child:DisplayObject;
            var wPref:Number;
            var hPref:Number
            
            for(var i:int = 0; i < n; i++)
            {
                child = target.getChildAt(i);
                
                if(child is IUIComponent)
                {
                    if(!IUIComponent(child).includeInLayout)
                    {
                        numChildrenWithOwnSpace--;
                        continue;
                    }
                    
                    wPref = IUIComponent(child).getExplicitOrMeasuredWidth();
                    hPref = IUIComponent(child).getExplicitOrMeasuredHeight();
                    
                    minWidth = Math.max(!isNaN(IUIComponent(child).percentWidth) ?
                                        IUIComponent(child).minWidth : wPref, minWidth);
                    
                    minHeight += !isNaN(IUIComponent(child).percentHeight) ?
                        IUIComponent(child).minHeight : hPref;
                }
                
                preferredWidth = Math.max(wPref, preferredWidth);
                preferredHeight += hPref;
            }
            
            var wPadding:Number = widthPadding(numChildrenWithOwnSpace);
            var hPadding:Number = heightPadding(numChildrenWithOwnSpace);
            
            if(target is IUIComponent)
            {
                IUIComponent(target).measuredMinWidth = minWidth + wPadding;
                IUIComponent(target).measuredMinHeight = minHeight + hPadding;
                
                target['measuredWidth'] = preferredWidth + wPadding;
                target['measuredHeight'] = preferredHeight + hPadding;
            }
        }
        
        override public function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            var children:Array = [];
            var n:int = target.numChildren;
            
            for(var i:int = 0; i < n; i++)
            {
                children.push(target.getChildAt(i));
            }
            
            var childList:IChildList = new ArrayChildList(children);
            var gap:Number = target is IStyleClient ? IStyleClient(target).getStyle("verticalGap") : 0;
            
            var numChildrenWithOwnSpace:int = n;
            var obj:DisplayObject;
            
            for(i = 0; i < n; i++)
            {
                obj = childList.getChildAt(i);
                
                if((obj is IUIComponent) && !IUIComponent(obj).includeInLayout)
                    numChildrenWithOwnSpace--;
            }
            
            // stretch everything as needed including heights
            var excessSpace:Number = Flex.flexChildHeightsProportionally(childList, h - (numChildrenWithOwnSpace - 1) * gap, w);
            
            var paddingLeft:Number = target is IStyleClient ? IStyleClient(target).getStyle("paddingLeft") : 0;
            var paddingTop:Number = target is IStyleClient ? IStyleClient(target).getStyle("paddingTop") : 0;
            var horizontalAlign:Number = getHorizontalAlignValue();
            var verticalAlign:Number = getVerticalAlignValue();
            
            var top:Number = paddingTop + excessSpace * verticalAlign;
            var left:Number = 0;
            
            for(i = 0; i < n; i++)
            {
                obj = childList.getChildAt(i);
                left = (w - obj.width) * horizontalAlign + paddingLeft;
                
                if(obj is IUIComponent)
                {
                    IUIComponent(obj).move(Math.floor(left), Math.floor(top));
                    if(IUIComponent(obj).includeInLayout)
                        top += obj.height + gap;
                }
                else
                {
                    obj.x = Math.floor(left);
                    obj.y = Math.floor(top);
                    top += obj.height + gap;
                }
            }
        }
        
        
        private function widthPadding(numChildren:Number):Number
        {
            return ((target is IStyleClient ? IStyleClient(target).getStyle('paddingLeft') : 0) + (target is IStyleClient ? IStyleClient(target).getStyle('paddingRight') : 0));
        }
        
        private function heightPadding(numChildren:Number):Number
        {
            return ((target is IStyleClient ? IStyleClient(target).getStyle('paddingTop') : 0) + (target is IStyleClient ? IStyleClient(target).getStyle('paddingBottom') : 0))
                + ((target is IStyleClient ? IStyleClient(target).getStyle('verticalGap') : 0) * (numChildren - 1));
        }
    }
}