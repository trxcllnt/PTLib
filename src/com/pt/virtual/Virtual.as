package com.pt.virtual
{
  public class Virtual
  {
    public function Virtual(... dimensions)
    {
      for each(var dimension:String in dimensions)
        addDimension(dimension);
    }
    
    protected var dimensions:Object = {};
    
    public function add(item:*, size:Number, dimension:String):*
    {
      if(!hasDimension(dimension))
        addDimension(dimension);
      
      return getDimension(dimension).add(item, size);
    }
    
    public function addAt(item:*, position:Number, size:Number, dimension:String):*
    {
      if(!hasDimension(dimension))
        addDimension(dimension);
      
      return getDimension(dimension).addAt(item, position, size);
    }
    
    public function addDimension(name:String):Dimension
    {
      if(name in dimensions)
        return dimensions[name];
      
      _size++;
      
      return dimensions[name] = new Dimension();
    }
    
    public function remove(item:*, dimension:String):*
    {
      if(!hasDimension(dimension))
        return item;
      
      return getDimension(dimension).remove(item);
    }
    
    public function removeDimension(name:String):Dimension
    {
      if(!(name in dimensions))
        return null;
      
      var dimension:Dimension = dimensions[name];
      dimension.clear();
      
      _size--;
      
      delete dimensions[name];
      
      return dimension;
    }
    
    public function updateSize(item:*, dimension:String, size:Number):*
    {
      if(!hasDimension(dimension))
        return item;
      
      return getDimension(dimension).updateSize(item, size);
    }
    
    public function updatePosition(item:*, dimension:String, position:Number):*
    {
      if(!hasDimension(dimension))
        return item;
      
      return getDimension(dimension).addAt(item, position);
    }
    
    public function getItems(dimension:String):Array
    {
      if(!hasDimension(dimension))
        return [];
      
      return getDimension(dimension).getItems();
    }
    
    public function getItemsAt(begin:Number, end:Number, dimension:String):Array
    {
      if(!hasDimension(dimension))
        return [];
      
      return getDimension(dimension).getBetween(begin, end);
    }
    
    public function getItemPosition(item:*, dimension:String):int
    {
        if(!hasDimension(dimension))
            return 0;
        
        return getDimension(dimension).getPosition(item);
    }
    
    public function getItemSize(item:*, dimension:String):int
    {
        if(!hasDimension(dimension))
            return 0;
        
        return getDimension(dimension).getSize(item);
    }
    
    public function getSize(dimension:String):int
    {
        if(!hasDimension(dimension))
            return 0;
        
        return getDimension(dimension).size;
    }
    
    public function getDimension(dimension:String):Dimension
    {
        if(!hasDimension(dimension))
            return null;
        
        return Dimension(dimensions[dimension]);
    }
    
    public function hasDimension(dimension:String):Boolean
    {
        return dimension in dimensions;
    }
    
    public function clear():void
    {
      for(var name:String in dimensions)
      {
        if(!dimensions[name])
          continue;
        
        Dimension(dimensions[name]).clear();
      }
      
      dimensions = {};
    }
    
    public function get dimensionNames():Object
    {
      var names:Object = {};
      for(var name:String in dimensions)
        names[name] = name;
      
      return names;
    }
    
    protected var _size:Number = 0;
    
    public function get size():Number
    {
      return _size;
    }
  }
}