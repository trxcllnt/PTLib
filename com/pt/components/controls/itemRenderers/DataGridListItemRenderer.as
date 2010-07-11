package com.pt.components.controls.itemRenderers
{
    import com.pt.components.containers.VirtualContainer;
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.controls.grid.DataGridColumn;
    import com.pt.virtual.Virtual;
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    
    import mx.core.IDataRenderer;
    import mx.core.IFactory;
    import mx.core.IUIComponent;
    import mx.core.ScrollPolicy;
    import mx.core.UIComponent;
    
    public class DataGridListItemRenderer extends UIComponent implements IDataRenderer
    {
        public function DataGridListItemRenderer()
        {
            super();
        }
        
        private var _data:Object;
        
        public function get data():Object
        {
            return _data;
        }
        
        public function set data(value:Object):void
        {
            _data = value;
            
            if(!data)
                return;
            
            var column:DataGridColumn;
            var renderer:DisplayObject;
            var n:int = columns.length;
            
            for(var i:int = 0; i < n; i++)
            {
                column = columns[i];
                renderer = getChildAt(i);
                
                if(column.rendererField in renderer)
                {
                    renderer[column.rendererField] = column.dataFunction(data);
                }
                else if('data' in renderer)
                {
                    renderer['data'] = column.dataFunction(data);
                }
            }
        }
        
        private var columnsChanged:Boolean = false;
        protected var _columns:Vector.<DataGridColumn> = new Vector.<DataGridColumn>();
        
        public function get columns():Vector.<DataGridColumn>
        {
            return _columns;
        }
        
        public function set columns(value:Vector.<DataGridColumn>):void
        {
            if(value === _columns)
                return;
            
            _columns = value;
            columnsChanged = true;
            
            createColumnRenderers();
            invalidateSize();
            invalidateDisplayList();
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(columnsChanged)
            {
                data = data;
            }
        }
        
        protected function createColumnRenderers():void
        {
            var n:int = columns.length;
            var column:DataGridColumn;
            var renderer:DisplayObject;
            var type:Class;
            
            for(var i:int = 0; i < n; i++)
            {
                column = columns[i];
                
                type = Class(column.itemRenderer.newInstance()['constructor']);
                
                renderer = i < numChildren ?
                    getChildAt(i) :
                    DisplayObject(new type());
                
                if(!(renderer is type))
                {
                    if(contains(renderer))
                        removeChildAt(i);
                    renderer = DisplayObject(new type());
                }
                
                if(!contains(renderer))
                    addChildAt(renderer, i);
                
                if(!isNaN(column.width))
                    renderer.width = column.width;
            }
            
            while(numChildren > n)
            {
                removeChildAt(numChildren - 1);
            }
        }
        
        override protected function measure():void
        {
            if(isNaN(explicitHeight))
                measuredHeight = 30;
            
            if(!columnsChanged)
                return;
            
            var column:DataGridColumn;
            var n:int = columns.length;
            var renderer:DisplayObject;
            for(var i:int = 0; i < n; i++)
            {
                column = columns[i];
                renderer = getChildAt(i);
                column.measuredWidth = Math.max(renderer is IUIComponent ?
                                                IUIComponent(renderer).getExplicitOrMeasuredWidth() :
                                                renderer.width,
                                                column.measuredWidth);
            }
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            if(!columnsChanged)
                return;
            
            var column:DataGridColumn;
            var n:int = columns.length;
            var renderer:DisplayObject;
            var aggregate:Number = 0;
            
            var g:Graphics = graphics;
            g.clear();
            g.lineStyle(1, 0xCCCCCC);
            
            for(var i:int = 0; i < n; i++)
            {
                column = columns[i];
                renderer = getChildAt(i);
                
                if(renderer is IUIComponent)
                {
                    IUIComponent(renderer).setActualSize(column.width || column.measuredWidth, h);
                    IUIComponent(renderer).move(column.x, 0);
                }
                else
                {
                    renderer.width = column.width;
                    renderer.x = column.x;
                }
                
                g.moveTo(renderer.x, h);
                g.lineTo(renderer.x + renderer.width, h);
                g.moveTo(renderer.x, 0);
                g.lineTo(renderer.x, h);
            }
            
            columnsChanged = false;
        }
    }
}