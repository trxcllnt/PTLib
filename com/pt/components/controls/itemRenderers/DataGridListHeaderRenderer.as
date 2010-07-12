package com.pt.components.controls.itemRenderers
{
    import com.pt.components.controls.grid.DataGridSegment;
    
    import flash.display.DisplayObject;

    public class DataGridListHeaderRenderer extends DataGridListItemRenderer
    {
        public function DataGridListHeaderRenderer()
        {
            super();
        }
        
        override protected function setData(data:Object):void
        {
            var segment:DataGridSegment;
            var renderer:DisplayObject;
            var n:int = segments.length;
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                renderer = getChildAt(i);
                
                if(segment.headerField && segment.headerField in renderer)
                {
                    renderer[segment.headerField] = segment.title;
                }
                else if('data' in renderer)
                {
                    renderer['data'] = segment.title;
                }
            }
        }
        
        override protected function createColumnRenderers():void
        {
            var n:int = segments.length;
            var segment:DataGridSegment;
            var renderer:DisplayObject;
            var type:Class;
            
            for(var i:int = 0; i < n; i++)
            {
                segment = segments[i];
                
                type = segment.header.generator;
                
                if(!pool.has(type))
                    pool.add(type);
                
                renderer = i < numChildren ?
                    getChildAt(i) :
                    DisplayObject(pool.checkOut(type));
                
                if(!(renderer is type))
                {
                    if(contains(renderer))
                    {
                        pool.checkIn(removeChild(renderer));
                    }
                    renderer = DisplayObject(pool.checkOut(type));
                }
                
                if(!contains(renderer))
                    addChildAt(renderer, i);
                
                if(!isNaN(segment.size))
                {
                    renderer[isV() ? 'height' : 'width'] = segment.size;
                }
            }
            
            while(numChildren > n)
            {
                pool.checkIn(removeChildAt(numChildren - 1));
            }
        }
    }
}