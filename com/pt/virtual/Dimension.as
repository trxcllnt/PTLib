package com.pt.virtual
{
  import de.polygonal.ds.DLinkedList;
  import de.polygonal.ds.DListIterator;
  import de.polygonal.ds.DListNode;
  
  import flash.utils.Dictionary;
  
  /**
  * Dimension represents items that have a size and position in a particular Dimension.
  * 
  * @author Paul Taylor (http://guyinthechair.com).
  */
  public class Dimension
  {
    protected var map:Dictionary = new Dictionary(false);
    protected var list:DLinkedList = new DLinkedList();
    
    public function add(item:*, size:Number):*
    {
      //Nodes can't have sizes less than 1
      if(size < 1)
        size = 1;
      
      var node:DListNode = (item in map) ? map[item] : list.append(new Data(item, size, _size));
      map[item] = node;
      //only whole numbers...
      map[Math.round(_size)] = node;
      
      _size += size;
      
      return item;
    }
    
    public function addAt(item:*, position:Number, size:Number = 0):*
    {
      if(list.isEmpty())
        return add(item, size);
      
      if(position < 0)
        position = 0;
      
      var begin:Number = position;
      while(!(begin in map) && begin > -1)
        begin--;
      
      var node:DListNode = map[begin];
      var data:Data = node.data;
      var itr:DListIterator = list.getListIterator();
      itr.node = node;
      
      if(item in map)
      {
        list.remove(itr);
        delete map[item];
        _size -= data.size;
        map[item] = list.insertBefore(itr, new Data(item, size, position));
      }
      else
        map[item] = list.insertAfter(itr, new Data(item, size, position));
      
      _size += size;
      
      return item;
    }
    
    public function remove(item:*):*
    {
      if(!(item in map))
        return item;
      
      var node:DListNode = map[item];
      var data:Data = node.data;
      var itr:DListIterator = new DListIterator(list, node);
      list.remove(itr);
      
      delete map[item];
      delete map[data.position];
      
      return item;
    }
    
    public function updateSize(item:*, newSize:Number):*
    {
      if(!(item in map))
        return item;
      
      var node:DListNode = map[item];
      if(newSize <= 0)
        newSize = 1;
      
      node.data.size = newSize;
      
      return item;
    }
    
    public function clear():void
    {
      list.clear();
      _size = 0;
      map = new Dictionary(false);
    }
    
    protected var _size:Number = 0;
    
    public function get size():Number
    {
      return _size;
    }
    
    public function getItemsAt(begin:Number, end:Number):Array
    {
      var a:Array = [];
      
      if(list.isEmpty())
        return a;
      
      if(begin < 0)
        begin = 0;
      
      while(!(begin in map) && begin > -1)
        begin--;
      
      var node:DListNode = map[begin];
      
      var itr:DListIterator = new DListIterator(list, node);
      var data:Data = Data(list.tail.data);
      
      if(end > (data.position + data.size))
        end = data.position + data.size;
      
      data = itr.data;
      while(itr.hasNext() && data)
      {
        if((data.position + data.size) <= begin)
        {
          itr.forth();
          data = itr.data;
        }
        else
          data = null;
      }
      
      data = itr.data;
      while(itr.hasNext() && data)
      {
        a.push(data.item);
        if(data.position < end)
        {
          itr.forth();
          data = itr.data;
        }
        else
          data = null;
      }
      
      return a;
    }
    
    public function getItemSize(item:*):int
    {
      if(!(item in map))
        return -1;
      
      return Data(DListNode(map[item]).data).size;
    }
    
    public function getItemPosition(item:*):int
    {
      if(!(item in map))
        return -1;
      
      return Data(DListNode(map[item]).data).position;
    }
    
    public function hasItem(item:*):Boolean
    {
      return (item in map);
    }
  }
}

internal class Data
{
  public var item:*;
  public var size:*;
  public var position:*;
  
  public function Data(item:*, size:Number, position:Number)
  {
    this.item = item;
    this.size = size;
    this.position = position;
  }
}