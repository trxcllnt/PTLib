package com.pt.components.controls.itemRenderers
{
    import com.pt.components.controls.grid.DataGridSegment;
    import com.pt.utils.MultiTypeObjectPool;
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class DataGridListItemRenderer extends DataGridListSegmentRenderer
    {
        protected static var pool:MultiTypeObjectPool = new MultiTypeObjectPool();
        
        private var _index:int = 0;
        
        public function get index():int
        {
            return _index;
        }
        
        public function set index(value:int):void
        {
            if(value === _index)
                return;
            
            _index = value;
            invalidateDisplayList();
        }
        
        override protected function commitRendererData(renderer:DisplayObject, segment:DataGridSegment):void
        {
            super.commitRendererData(renderer, segment);
            
            if('index' in renderer)
                renderer['index'] = index;
        }
        
        private var bgRect:Rectangle = new Rectangle();
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            if(segments.length)
            {
                var first:DataGridSegment = segments[0];
                var fPos:Point = first.position;
                var last:DataGridSegment = segments[segments.length - 1];
                var lPos:Point = last.position;
                
                bgRect = new Rectangle(fPos.x, fPos.y,
                    lPos.x + (isV() ? w : last.size), 
                    lPos.y + (isV() ? last.size : h));
            }
            else
            {
                bgRect = new Rectangle(0, 0, w, h);
            }
            
            var g:Graphics = graphics;
            g.clear();
            g.beginFill(index % 2 == 0 ? 0xFFFFFF : 0xDDEEFF, 1);
            g.drawRect(bgRect.x, bgRect.y, bgRect.width, bgRect.height);
        }
    }
}