package com.pt.components.containers.data
{
  import flash.utils.Dictionary;
  import flash.utils.getTimer;
  
  import mx.utils.UIDUtil;
  
  public class RepeaterData
  {
    public function RepeaterData()
    {
    }
    
    private var descriptors:XML = <_ size="0"/>;
    private var map:Dictionary = new Dictionary();
    
    public function clear():void
    {
      descriptors = <_ size="0"/>;
      map = new Dictionary();
    }
    
    public function addItem(item:Object, length:int = 1):Object
    {
      var uid:String = UIDUtil.createUID();
      descriptors.appendChild(<item index={items.length()} position={size} length={length} id={uid}/>);
      
      descriptors.@size = size + length;
      
      map[uid] = item;
      map[item] = uid;
      return item;
    }
    
    public function getItemAtPosition(position:int):Object
    {
      if(position > size)
        position = size;
      
      return map[items.(@position >= position)[0].@id.toString()];
    }
    
    public function getItemAtIndex(index:int):Object
    {
      if(index > size)
        index = size;
      
      return map[items.(@index >= index)[0].@id.toString()];
    }
    
    public function getItemIndex(item:Object):int
    {
      return items.(attribute("id") == map[item]).attribute("index");
    }
    
    public function getItemLength(item:Object):int
    {
      return items.(attribute("id") == map[item]).attribute("length");
    }
    
    public function getItemPosition(item:Object):int
    {
      return items.(attribute("id") == map[item]).attribute("position");
    }
    
    public function getItemsBetweenPositions(beginPosition:int, endPosition:int, extraIndicies:int = 1):Array
    {
      if(beginPosition < 0)
        beginPosition = 0;
      
      if(endPosition > size)
        endPosition = size;
      
      if(items.length() == 0)
        return[];
      
      // This is more efficient on large data sets at earlier indicies than a fancy e4x query.
      var a:Array = [];
      var pos:int = 0;
      var len:int = 0;
      var idx:int = 0;
      for each(var child:XML in items)
      {
        pos = int(child.@position);
        len = int(child.@length);
        idx = int(child.@index);
        
        if(beginPosition < (pos + len) && endPosition >= (pos + len))
          a.push(map[String(child.@id)]);
        else if((pos + len) > endPosition)
        {
          if(extraIndicies-- > 0)
            a.push(map[String(child.@id)]);
          else
            break;
        }
      }
      
      return a;
    }
    
    public function get size():Number
    {
      return descriptors.@size;
    }
    
    public function get length():Number
    {
      return descriptors.children().length();
    }
    
    protected function get items():XMLList
    {
      return descriptors.descendants().(attribute("length").length() > 0);
    }
  }
}