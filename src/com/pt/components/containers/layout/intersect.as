package com.pt.components.containers.layout
{
    import flash.utils.Dictionary;

    public function intersect(...arrays):Array
    {
        if(arrays.length == 0)
            return [];
        if(arrays.length == 1)
            return arrays[0];
        
        arrays.sortOn("length");
        
        var a:Array = [];
        var m:Array, obj:*;
        var map:Dictionary = new Dictionary();
        
        var intersections:Array = [];
        
        for each(m in arrays)
        {
            for each(obj in m)
            {
                if(!(obj in map))
                {
                    map[obj] = intersections.length;
                    map[intersections.length] = obj;
                    intersections.push([]);
                }
                
                intersections[map[obj]].push(0);
            }
        }
        
        var n:int = intersections.length;
        
        for(var i:int = 0; i < n; i++)
        {
            m = intersections[i];
            if(m.length === arrays.length)
                a.push(map[i]);
        }
        
        return a;
    }
}