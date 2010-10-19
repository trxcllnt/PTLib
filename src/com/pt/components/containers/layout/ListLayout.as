package com.pt.components.containers.layout
{
    import com.pt.components.controls.DataList;
    import com.pt.virtual.Dimension;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    import mx.core.IUIComponent;

    public class ListLayout extends ComponentLayout
    {
        public function get list():DataList
        {
            return DataList(target);
        }
        
        override public function updateDisplayList(w:Number, h:Number):void
        {
            var renderer:DisplayObject;
            var item:*;
            
            var aggregate:Number = 0;
            var dimension:Dimension = list.dimension;
            
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
                
                childPos.x = 0;
                
                childPos.y = aggregate;
                
                if(list.variableItemSize)
                {
                    if(renderer is IUIComponent)
                    {
                        childSize.x = w;
                        childSize.y = IUIComponent(renderer).getExplicitOrMeasuredHeight();
                    }
                    else
                    {
                        childSize.x = w;
                        childSize.y = renderer.height;
                    }
                }
                else
                {
                    childSize.x = w;
                    childSize.y = list.itemSize;
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
                
                if('horizontalScrollPosition' in renderer)
                {
                    renderer['horizontalScrollPosition'] = list.horizontalScrollPosition;
                }
                
                aggregate += childSize.y;
            }
        }
    }
}