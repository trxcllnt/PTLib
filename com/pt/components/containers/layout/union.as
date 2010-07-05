package com.pt.components.containers.layout
{
  import flash.utils.Dictionary;
  
  /**
  * Probably the slowest way possible to union arrays...
  */
  public function union(...arrays):Array
  {
    var i:int = 0;
    var len:int = arrays.length;
    
    if(len == 0)
      return [];
    
    if(len == 1)
      return arrays[0];
    
    var dict:Dictionary = new Dictionary(true);
    var j:int = 0;
    var k:int = 0;
    
    for(i = 0; i < len; i++)
    {
      k = arrays[i].length;
      for(j = 0; j < k; j++)
        dict[arrays[i][j]] = arrays[i][j];
    }
    
    var a:Array = [];
    for(var item:* in dict)
      a.push(item);
    
    return a;
  }
}