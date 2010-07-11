package com.pt.components.controls.grid
{
    import com.pt.components.controls.DataList;
    import com.pt.components.controls.itemRenderers.DataGridListItemRenderer;
    import com.pt.virtual.Dimension;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    public class DataGridList extends DataList
    {
        public function DataGridList()
        {
            direction = VERTICAL;
            variableItemSize = false;
            itemRenderer = DataGridListItemRenderer;
        }
        
        public function get columnDirection():String
        {
            if(direction == HORIZONTAL)
                return VERTICAL;
            
            return HORIZONTAL;
        }
        
        protected var _columns:Vector.<DataGridColumn> = new Vector.<DataGridColumn>();
        private var columnsChanged:Boolean = false;
        
        public function get columns():Vector.<DataGridColumn>
        {
            return _columns;
        }
        
        public function set columns(value:Vector.<DataGridColumn>):void
        {
            if(value === _columns)
                return;
            
            _columns = value;
            visibleColumns = _columns;
            itemRendererChanged = true;
            invalidateSize();
            invalidateDisplayList();
        }
        
        override protected function processRendererData():Boolean
        {
            return super.processRendererData() || newRendererInView.x;
        }
        
        private var visibleColumns:Vector.<DataGridColumn> = new Vector.<DataGridColumn>();
        
        override protected function commitRendererData():void
        {
            if(!processRendererData())
                return;
            
            if(dataProviderChanged || itemRendererChanged || newRendererInView.x)
            {
                var minPosition:Number = isV() ? scrollRect.x : scrollRect.y;
                var maxPosition:Number = minPosition + (isV() ? scrollRect.width : scrollRect.height);
                
                var items:Array = getDimension(columnDirection).getBetween(minPosition, maxPosition);
                visibleColumns = Vector.<DataGridColumn>(items);
                trace(visibleColumns.length);
            }
            
            super.commitRendererData();
        }
        
        override protected function setRendererData(renderer:DisplayObject, data:Object):void
        {
            if(renderer is DataGridListItemRenderer)
            {
                DataGridListItemRenderer(renderer).columns = visibleColumns;
            }
            
            super.setRendererData(renderer, data);
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            var column:DataGridColumn;
            var n:int = columns.length;
            var cX:Number = 0;
            
            for(var i:int = 0; i < n; i++)
            {
                column = columns[i];
                column.x = cX;
                cX += column.width;
            }
            
            if(visibleColumns.length)
            {
                var scrollIndex:int = isV() ? 1 : 0;
                var d:Dimension = getDimension(columnDirection);
                column = visibleColumns[0];
                scrollDelta[scrollIndex].x = d.getPosition(column);
                column = visibleColumns[visibleColumns.length - 1];
                scrollDelta[scrollIndex].y = d.getPosition(column) + d.getSize(column);
            }
            
            super.updateDisplayList(w, h);
        }
        
        override protected function measureAllDataItems():void
        {
            super.measureAllDataItems();
            
            var d:Dimension = getDimension(columnDirection);
            d.clear();
            var column:DataGridColumn;
            var n:int = columns.length;
            
            for(var i:int = 0; i < n; i++)
            {
                column = columns[i];
                
                if(isNaN(column.width))
                    column.width = column.measuredWidth;
                
                d.add(column, column.width);
            }
            
            measuredWidth = d.size;
        }
    }
}