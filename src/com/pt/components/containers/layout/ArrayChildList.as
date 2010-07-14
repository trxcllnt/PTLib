package com.pt.components.containers.layout
{
  import flash.display.DisplayObject;
  import flash.errors.IllegalOperationError;
  import flash.geom.Point;
  
  import mx.core.IChildList;
  
  public class ArrayChildList implements IChildList
  {
    protected var list:Array = [];
    
    public function ArrayChildList(list:Array = null)
    {
      if(list)
        this.list = [].concat(list);
    }
    
    public function get numChildren():int
    {
      return list.length;
    }
    
    public function addChild(child:DisplayObject):DisplayObject
    {
      if(list.indexOf(child) < 0)
        list.push(child);
      
      return child;
    }
    
    public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
      if(list.length < index)
        throw new IllegalOperationError("Index out of bounds.");
      
      return list[index] = child;
    }
    
    public function removeChild(child:DisplayObject):DisplayObject
    {
      if(list.indexOf(child) < 0)
        throw new IllegalOperationError("The supplied DisplayObject must be a child of the caller.");
      
      return list.splice(list.indexOf(child), 1)[0];
    }
    
    public function removeChildAt(index:int):DisplayObject
    {
      if(list.length < index)
        throw new IllegalOperationError("Index out of bounds.");
      
      return list.splice(index, 1)[0];
    }
    
    public function getChildAt(index:int):DisplayObject
    {
      if(list.length < index)
        throw new IllegalOperationError("Index out of bounds.");
      
      return list[index];
    }
    
    public function getChildByName(name:String):DisplayObject
    {
      var items:Array = list.filter(function(e:DisplayObject, ...args):Boolean
      {
        return e.name == name;
      });
      
      if(items.length == 0)
        throw new IllegalOperationError("No child with the name " + name + " exists on this object.");
      
      return items[0];
    }
    
    public function getChildIndex(child:DisplayObject):int
    {
      return list.indexOf(child);
    }
    
    public function setChildIndex(child:DisplayObject, newIndex:int):void
    {
      if(newIndex > list.length)
        throw new IllegalOperationError("Index out of bounds.");
      
      if(list.indexOf(child))
        list.splice(newIndex, 0, list.splice(list.indexOf(child), 1)[0]);
    }
    
    public function getObjectsUnderPoint(point:Point):Array
    {
      return [].concat(list);
    }
    
    public function contains(child:DisplayObject):Boolean
    {
      return list.some(function(e:DisplayObject, ...args):Boolean{
        return e == child;
      });
    }
  }
}