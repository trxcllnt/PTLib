package com.pt.components.controls.grid.itemRenderers.layout
{
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.controls.grid.itemRenderers.DataGridSegmentRendererBase;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    import mx.containers.BoxDirection;
    import mx.core.IUIComponent;
    
    public class DataGridSegmentRendererLayout extends ComponentLayout
    {
        public var segments:Vector.<DataGridSegment>;
        
        override public function measure():void
        {
            if(!segments || segments.length == 0)
                return;
            
            var segment:DataGridSegment;
            var n:int = Math.min(segments.length, target.numChildren);
            var r:DisplayObject;
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                r = target.getChildAt(i);
                
                if(r is IUIComponent)
                {
                    if(isV())
                        segment.measuredSize = Math.max(IUIComponent(r).getExplicitOrMeasuredWidth(), segment.measuredSize);
                    else
                        segment.measuredSize = Math.max(IUIComponent(r).getExplicitOrMeasuredHeight(), segment.measuredSize);
                }
                else
                {
                    if(isV())
                        segment.measuredSize = Math.max(r.width, segment.measuredSize);
                    else
                        segment.measuredSize = Math.max(r.height, segment.measuredSize);
                }
            }
        }
        
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
            
            var percentTotal:Number = 0;
            var usedSpace:Number = 0;
            
            for(i = 0; i < n; ++i)
            {
                segment = segments[i];
                if(isNaN(segment.percentSize))
                {
                    segment.size = Math.min(Math.max(segment.size, segment.measuredSize, segment.relativeMinSize), segment.maxSize);
                    usedSpace += segment.size;
                }
                else
                {
                    percentTotal += segment.percentSize;
                }
            }
            
            var spacePerCent:Number = ((isV() ? w : h) - usedSpace) / Math.max(percentTotal, 100);
            var sPer:Number = 0;
            var aggregatePosition:Number = 0;
            
            for(i = 0; i < n; i++)
            {
                segment = segments[i];
                
                pos = segment.position;
                
                if(i == 0)
                {
                    aggregatePosition = pos[isV() ? 'x' : 'y'];
                }
                
                if(isNaN(segment.percentSize))
                {
                    segment.size = Math.min(Math.max(segment.size, segment.measuredSize, segment.relativeMinSize), segment.maxSize);
                }
                else
                {
                    sPer = segment.percentSize * spacePerCent;
                    if(sPer > segment.maxSize)
                    {
                        usedSpace += segment.maxSize;
                        percentTotal -= segment.percentSize;
                        spacePerCent = ((isV() ? w : h) - usedSpace) / Math.max(percentTotal, 100);
                    }
                    segment.size = Math.min(Math.max(Math.round(sPer), segment.relativeMinSize), segment.maxSize);
                }
                
                segment.position[isV() ? 'x' : 'y'] = aggregatePosition;
                
                aggregatePosition += segment.size;
                
                r = target.getChildAt(i);
                
                pos = segment.position;
                
                if(isV())
                {
                    size.x = segment.size;
                    size.y = h;
                }
                else
                {
                    size.x = w;
                    size.y = segment.size;
                }
                
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
            }
        }
        
        private function isV():Boolean
        {
            return renderer.direction != BoxDirection.VERTICAL;
        }
        
        private function get renderer():DataGridSegmentRendererBase
        {
            return target as DataGridSegmentRendererBase;
        }
    }
}