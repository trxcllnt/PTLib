package com.pt.components.controls.itemRenderers.grid.layout
{
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.components.controls.itemRenderers.grid.DataGridListSegmentRenderer;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    import mx.containers.BoxDirection;
    import mx.core.IUIComponent;
    
    public class SegmentRendererLayout extends ComponentLayout
    {
        public function SegmentRendererLayout()
        {
            super();
        }
        
        public var segments:Vector.<DataGridSegment>;
        
        override public function measure():void
        {
            if(!segments || segments.length == 0)
                return;
            
            var segment:DataGridSegment;
            var n:int = segments.length;
            var r:DisplayObject;
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                r = target.getChildAt(i);
                if(r is IUIComponent)
                    segment.measuredSize = Math.max(IUIComponent(r)[isV() ? 'getExplicitOrMeasuredHeight' : 'getExplicitOrMeasuredWidth'](), segment.measuredSize);
                else
                    segment.measuredSize = Math.max(r[isV() ? 'height' : 'width'], segment.measuredSize);
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
            var n:int = segments.length;
            var r:DisplayObject;
            var segment:DataGridSegment;
            var segmentSize:Number;
            
            for(i = 0; i < n; i++)
            {
                segment = segments[i];
                
                r = target.getChildAt(i);
                
                segmentSize = segment.size || 0;
                
                pos = segment.getRelativePosition();
                
                if(isV())
                {
                    size.x = w;
                    size.y = segmentSize;
                }
                else
                {
                    size.x = segmentSize;
                    size.y = h;
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
            return renderer.direction == BoxDirection.VERTICAL;
        }
        
        private function get renderer():DataGridListSegmentRenderer
        {
            return target as DataGridListSegmentRenderer;
        }
    }
}