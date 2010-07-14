package com.pt.components.containers.layout
{
    import com.pt.components.controls.DataList;
    import com.pt.virtual.Dimension;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    import mx.containers.BoxDirection;
    import mx.core.IUIComponent;

    public class ListLayout extends ComponentLayout
    {
        public function get list():DataList
        {
            return DataList(target);
        }
        
        protected function isV():Boolean
        {
            return list.direction == BoxDirection.VERTICAL;
        }
        
        override public function updateDisplayList(w:Number, h:Number):void
        {
            var renderer:DisplayObject;
            var item:*;
            
            var aggregate:Number = 0;
            var dimension:Dimension = list.getDimension(list.direction);
            
            var i:int = 0;
            var n:int = target.numChildren;
            var childSize:Point = new Point();
            var childPos:Point = new Point();
            var scrollProp:String;
            
            for(i = 0; i < n; i++)
            {
                renderer = target.getChildAt(i);
                item = renderer['data'];
                
                if(i == 0)
                {
                    aggregate += dimension.getPosition(item);
                }
                
                childPos.x = isV() ? 0 : aggregate;
                
                childPos.y = isV() ? aggregate : 0;
                
                if(list.variableItemSize)
                {
                    if(renderer is IUIComponent)
                    {
                        childSize.x = isV() ? w : IUIComponent(renderer).getExplicitOrMeasuredWidth();
                        childSize.y = isV() ? IUIComponent(renderer).getExplicitOrMeasuredHeight() : h;
                    }
                    else
                    {
                        childSize.x = isV() ? w : renderer.width;
                        childSize.y = isV() ? renderer.height : h;
                    }
                }
                else
                {
                    childSize.x = isV() ? w : list.itemSize;
                    childSize.y = isV() ? list.itemSize : h;
                }
                
                if(renderer is IUIComponent)
                {
                    IUIComponent(renderer).setActualSize(childSize.x, childSize.y);
                    IUIComponent(renderer).move(childPos.x, childPos.y);
                }
                else
                {
                    renderer.width = childSize.x;
                    renderer.height = childSize.y;
                    renderer.x = childPos.x;
                    renderer.y = childPos.y;
                }
                
                scrollProp = isV() ? 'horizontalScrollPosition' : 'verticalScrollPosition';
                
                if(scrollProp in renderer)
                {
                    renderer[scrollProp] = isV() ? list.horizontalScrollPosition : list.verticalScrollPosition;
                }
                
                aggregate += isV() ? childSize.y : childSize.x;
            }
        }
    }
}