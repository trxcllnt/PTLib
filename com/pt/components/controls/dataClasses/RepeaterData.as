package com.pt.components.controls.dataClasses
{
  import flash.utils.Dictionary;
  import flash.utils.getTimer;
  
  import mx.utils.UIDUtil;
  
  public class RepeaterData
  {
    public function RepeaterData()
    {
    }
    
    private var descriptors:Array = [];
    private var itemMap:Dictionary = new Dictionary();
    private var _size:Number = 0;
    
    public function clear():void
    {
      descriptors = [];
      itemMap = new Dictionary();
    }
    
    public function addItem(item:Object, length:int = 1):Object
    {
      itemMap[size] = item;
      itemMap[item] = {index:descriptors.push(item), length:length, position:size}
      _size += length;
      
      return item;
    }
    
    public function getItemAtPosition(position:int):Object
    {
      var item:* = itemMap[position];
      
      var i:int = position;
      while(!item && i >= 0)
      {
        item = itemMap[i--];
      }
      
      return item;
    }
    
    public function getItemAtIndex(index:int):Object
    {
      if(index > descriptors.length)
        return null;
      
      return descriptors[index];
    }
    
    public function getItemIndex(item:Object):int
    {
      return itemMap[item].index;
    }
    
    public function getItemLength(item:Object):int
    {
      return itemMap[item].length;
    }
    
    public function getItemPosition(item:Object):int
    {
      return itemMap[item].position;
    }
    
    public function getItemsBetweenPositions(beginPosition:int, endPosition:int, extraIndicies:int = 1):Array
    {
      if(beginPosition < 0)
        beginPosition = 0;
      
      if(endPosition > size)
        endPosition = size;
      
      if(descriptors.length <= 0)
        return[];
      
      var time:Number = getTimer();
      
      var item:* = getItemAtPosition(beginPosition);
      var index:int = getItemIndex(item);
      var extras:int = 0;
      var a:Array = [];
      
      var reachedEnd:Boolean = false;
      
      while(!reachedEnd)
      {
        a.push(item);
        item = getItemAtIndex(index++);
        if(!item || (getItemPosition(item) > endPosition && ++extras >= extraIndicies))
          reachedEnd = true;
      }
      
      trace(getTimer() - time);
      
      return a;
    }
    
    public function get size():int
    {
      return _size;
    }
  }
}