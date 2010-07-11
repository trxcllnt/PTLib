package com.pt.utils
{
  import flash.display.DisplayObject;
  import flash.utils.Proxy;
  import flash.utils.flash_proxy;
  
  public class Replicator extends Proxy
  {
    private var pool:ObjectPool;
    private var replicants:Array;
    
    public var dataField:* = "data";
    
    public function Replicator()
    {
      super();
      
      pool = new ObjectPool(Object, 0);
      replicants = [];
    }
    
    public function get factoryClass():Class
    {
      return pool.generator;
    }
    
    public function set factoryClass(type:Class):void
    {
      if(type === pool.generator)
        return;
      
      pool.empty();
      pool.generator = type;
    }
    
    public function getReplicants(list:Object):Array
    {
      var len:int = 0;
      if(list is Array)
      {
        for(var i:int = 0; i < list.length; i++)
          retrieveReplicant(list[i]);
        
        len = list.length;
      }
      else
      {
        for each(var value:* in list)
        {
          retrieveReplicant(value);
          len++;
        }
      }
      
      while(replicants.length > len)
        returnReplicant(replicants.pop());
      
      return replicants;
    }
    
    public function clear():void
    {
      while(replicants.length > 0)
        returnReplicant(replicants.pop());
    }
    
    public function retrieveReplicant(value:* = null):*
    {
      var obj:*;
      
      if(replicants.length < pool.size)
        obj = pool.checkOut();
      else
        obj = pool.add();
      
      if(dataField in obj)
        obj[dataField] = value;
      
      return obj;
    }
    
    public function returnReplicant(replicant:*):void
    {
      if(dataField in replicant)
        replicant[dataField] = null;
      
      if(replicant is DisplayObject && replicant.parent && replicant.parent.contains(replicant))
        replicant.parent.removeChild(replicant);
      
      var i:int = replicants.indexOf(replicant);
      if(i != -1)
        replicants.splice(i, 1);
      
      pool.checkIn(replicant);
    }
  }
}