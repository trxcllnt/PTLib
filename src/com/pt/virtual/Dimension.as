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
    private var accuracy:int = 1;

    /**
     * The delta to increment by when searching through the map. This value can
     * never be less than one, because one is the smallest increment allowed into the map.
     * Set to a larger value to make searches more speedy, but less accurate.
     */
    public function get searchAccuracy():int
    {
      return accuracy;
    }

    private var overlap:Boolean = false;

    public function get allowOverlap():Boolean
    {
      return overlap;
    }

    private var overlapSet:Boolean = false;

    public function set allowOverlap(value:Boolean):void
    {
      if(overlapSet)
        return;

      overlapSet = true;
      overlap = value;
    }

    public function set searchAccuracy(value:int):void
    {
      if(value < 1)
        value = 1;

      accuracy = value;
    }

    protected var map:Dictionary = new Dictionary(false);
    protected var index:Dictionary = new Dictionary(false);
    protected var list:DLinkedList = new DLinkedList();

    /**
     * Appends an item with the specified size to the end of the dimension.
     */
    public function add(item:*, size:int = 1):*
    {
      //Nodes can't have sizes less than 1
      if(size < 1)
        size = 1;

      var node:DListNode = has(item) ? map[item] : list.append(new Data(item, size, _size));
      var data:Data = Data(node.data);
      var position:int = data.position;

      if(has(item))
      {
        if(list.head == node)
          list.head = node.next;

        list.tail.insertAfter(node);
        list.tail = node;

        _size -= data.size;
      }

      map[item] = node;

      if(!(_size in map))
        map[_size] = [item];
      else
        map[_size].push(item);

      _size += size;

      index[item] = _length;
      ++_length;

      return item;
    }

    /**
     * Adds an item to the list at a particular position. If this list
     * doesn't allow overlapping, update the positions of all the items
     * after this position.
     */
    public function addAt(item:*, position:int, size:int = 1):*
    {
      if(list.isEmpty())
        return add(item, size);

      if(position < 0)
        position = 0;

      var nodeData:Data;
      //  If we already have the item, first remove him from his current place.
      if(has(item))
      {
        nodeData = Data(map[item].data);
        size = size || nodeData.size;
        remove(item);
      }

      //  Now, we have to get the item at or before the position we're 
      //  inserting to.
      var startPos:int = position;

      var startItem:*;
      var begin:DListNode;
      var node:DListNode;
      var itr:DListIterator = list.getListIterator();
      var idx:int;

      if(has(startPos))
      {
        startItem = map[startPos][0];
        begin = map[startItem];
        itr.node = begin;
        node = list.insertBefore(itr, nodeData = new Data(item, size, position));
      }
      else
      {
        startPos = normalizePosition(position);
        startItem = map[startPos][0];
        begin = map[startItem];
        itr.node = begin;
        node = list.insertAfter(itr, nodeData = new Data(item, size, position));
      }

      map[item] = node;
      index[item] = getIndex(startItem);
      ++_length;

      if(!has(position))
        map[position] = [item];
      else
        map[position].push(item);

      //Update the size of the dimension
      _size = overlap ? Math.max(_size, position + size) : _size + size;

      //TODO: Update the the positions of all the nodes after this one.

      return item;
    }

    public function remove(item:*):*
    {
      if(!has(item))
        return item;

      var node:DListNode = DListNode(map[item]);
      var data:Data = Data(node.data);

      delete map[item];
      delete index[item];
      --_length;

      var itr:DListIterator = new DListIterator(list, node);
      list.remove(itr);

      var pos:int = data.position;
      if(has(pos))
      {
        map[pos].splice(map[pos].indexOf(item), 1);
        if(map[pos].length == 0)
          delete map[pos];
      }

      _size -= data.size;

      return item;
    }

    public function removeAt(position:int, exact:Boolean = true):*
    {
      return null;
    }

    public function updateSize(item:*, newSize:int):*
    {
      if(!has(item))
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
      _length = 0;
      index = new Dictionary(false);
      map = new Dictionary(false);
    }

    protected var _size:int = 0;
    protected var _length:int = 0;

    public function get size():int
    {
      return _size;
    }

    public function getItems():Array
    {
      var a:Array = [];
      var node:DListNode = list.head;
      while(node)
      {
        a.push(Data(node.data).item);
        node = node.next;
      }
      return a;
    }

    /**
     * Gets an item from the dimension, with options to search for the item if
     * the supplied index isn't exact. You can search either forwards or backwards,
     * with backwards being the default option.
     *
     * @param position The index to retrieve (or start from if you are searching) from the list
     */
    public function getAt(position:int):*
    {
      if(position < 0)
        position = 0;
      else if(position > size)
        position = size;

      var items:Array = map[normalizePosition(position)];
      return (items.length == 1) ? items[0] : items;
    }

    /**
     * Returns an Array of the items between the two indicies, inclusive.
     * This performs two searches, one for the item at or before the begin index,
     * and one for the item at or after the end index.
     * @param begin The index of the first item to retrieve. This searchs
     * backwards, finding the item that has a position less than the begin index
     * but is kept in bounds by its size.
     * @param end The index of the last item to retrieve. This searches forward,
     * finding the item that has a position less than the end index, but is kept in
     * bounds by its size.
     */
    public function getBetween(begin:int, end:int):Array
    {
      var a:Array = [];

      if(list.isEmpty())
        return a;

      //Normalize the inputs so that begin is always less than end.
      var temp:int = begin;
      begin = Math.min(begin, end);
      end = Math.min(Math.max(temp, end), size);

      //Get the node at the beginning index we request
      var beginItem:* = getAt(begin);
      var node:DListNode = map[beginItem];
      //Add his item first.

      //Get the node at the end index requested
      var endItem:* = getAt(end);
      var endNode:DListNode = map[endItem];

      //Get all the nodes in between, saving the data off each time.
      while(node != endNode)
      {
        a.push(node.data.item);
        node = node.next;
      }

      if(endNode && a.indexOf(endNode.data.item) == -1)
        a.push(endNode.data.item);

      return a;
    }

    public function getSize(item:*):int
    {
      if(!has(item))
        return -1;

      return Data(DListNode(map[item]).data).size;
    }

    public function getPosition(item:*):int
    {
      if(!has(item))
        return -1;

      return Data(DListNode(map[item]).data).position;
    }

    public function getIndex(item:*):int
    {
      if(!has(item))
        return -1;

      return int(index[item]);
    }

    public function has(item:*):Boolean
    {
      return (item in map);
    }

    public function get length():int
    {
      return _length;
    }

    public function sort(sortFunction:Function, ... sortOptions):void
    {
      list.sort.apply(null, [function(data1:Data, data2:Data):Boolean
        {
          return sortFunction(data1.item, data2.item);
        }].concat(sortOptions));
      
      var a:Array = list.toArray();
      
      clear();
      var n:int = a.length;
      for(var i:int = 0; i < n; i++)
      {
        add(a[i].item, a[i].size);
      }
    }

    private function normalizePosition(position:int):int
    {
      while(!has(position) && position >= 0)
        position -= accuracy;

      return Math.max(position, 0);
    }
  }
}
import flash.utils.Dictionary;

internal class Data
{
  public var item:*;
  public var size:int = 0;
  public var position:int = 0;

  public function Data(item:*, size:int, position:int = 0)
  {
    this.item = item;
    this.size = size;
    this.position = position;
  }
}