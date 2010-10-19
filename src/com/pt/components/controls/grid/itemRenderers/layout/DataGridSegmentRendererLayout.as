package com.pt.components.controls.grid.itemRenderers.layout
{
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.controls.grid.itemRenderers.DataGridSegmentRendererBase;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    import mx.core.IUIComponent;
    
    public class DataGridSegmentRendererLayout extends ComponentLayout
    {
        public var segments:Vector.<DataGridSegment>;
        
        override public function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            if(!segments || segments.length == 0)
                return;
            
            var size:Point = new Point();
            var pos:Point = new Point();
            var i:int = 0;
            var n:int = Math.min(segments.length, target.numChildren);
            var r:DisplayObject;
            var segment:DataGridSegment;
            
            var usedSpace:Number = 0;
            var numSegmentsWithLeftOverSpace:int = 0;
            
            for(i = 0; i < n; i++)
            {
                segment = segments[i];
                if(isNaN(segment.size))
                {
                  numSegmentsWithLeftOverSpace++;
                }
                else
                {
                  usedSpace += segment.size;
                }
            }
            
            var defaultSize:Number = (w - usedSpace) / numSegmentsWithLeftOverSpace;
            
            for(i = 0; i < n; i++)
            {
                segment = segments[i];
                
                if(i == 0)
                {
                  pos = segment.position.clone();
                }
                
                segment.measuredSize = Math.min(Math.max(segment.size || defaultSize, segment.relativeMinSize), segment.maxSize);
                
                size.x = segment.measuredSize;
                size.y = h;
                usedSpace += size.x;
                
                if(isNaN(segment.size))
                {
                    numSegmentsWithLeftOverSpace--;
                    
                    if(numSegmentsWithLeftOverSpace <= 0)
                      numSegmentsWithLeftOverSpace = 1;
                    
                    if(segment.maxSize < defaultSize)
                    {
                        defaultSize = (w - usedSpace) / numSegmentsWithLeftOverSpace;
                    }
                }
                
                r = target.getChildAt(i);
                
                if(r is IUIComponent)
                {
                    IUIComponent(r).setActualSize(size.x, size.y);
                    IUIComponent(r).move(pos.x, pos.y);
                }
                else
                {
                    r.width = size.x;
                    r.height = size.y;
                    r.x = pos.x;
                    r.y = pos.y;
                }
                
                segment.position.x = pos.x;
                
                pos.x += size.x;
            }
        }
    }
}