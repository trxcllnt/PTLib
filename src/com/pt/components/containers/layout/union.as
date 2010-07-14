package com.pt.components.containers.layout
{
    import flash.utils.Dictionary;
    
    /**
     * Probably the slowest way possible to union arrays...
     */
    public function union(... arrays):Array
    {
        var n:int = arrays.length;
        
        if(n == 0)
            return [];
        
        if(n == 1)
            return arrays[0];
        
        var dict:Dictionary = new Dictionary(true);
        var i:int = 0;
        var j:int = 0;
        var k:int = 0;
        var a:Array = [];
        var item:*;
        
        for(i = 0; i < n; i++)
        {
            k = arrays[i].length;
            for(j = 0; j < k; j++)
            {
                item = arrays[i][j];
                if(!(item in dict))
                {
                    dict[item] = true;
                    a.push(item);
                }
            }
        }
        
        return a;
    }
}