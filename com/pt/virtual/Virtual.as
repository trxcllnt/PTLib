package com.pt.virtual
{
  public class Virtual
  {
    public function Virtual(... dimensions)
    {
      for each(var dimension:String in dimensions)
        dimensions[dimension] = new Dimension();
    }
    
    protected var dimensions:Object = {};
    
    public function add(item:*, size:Number, dimension:String):*
    {
      if(!(dimension in dimensions))
        addDimension(dimension);
      
      return Dimension(dimensions[dimension]).add(item, size);
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
      if(!(dimension in dimensions))
        return item;
      
      return Dimension(dimensions[dimension]).remove(item);
    }
    
    public function removeDimension(name:String):Dimension
    {
      if(!(name in dimensions))
        return null;
      
      var dimension:Dimension = dimensions[name];
      dimension.clear();
      
      delete dimensions[name];
      
      return dimension;
    }
    
    public function updateSize(item:*, dimension:String, size:Number):*
    {
      if(!(dimension in dimensions))
        return item;
      
      return Dimension(dimensions[dimension]).updateSize(item, size);
    }
    
    public function updatePosition(item:*, dimension:String, position:Number):*
    {
      if(!(dimension in dimensions))
        return item;
      
      return Dimension(dimensions[dimension]).addAt(item, position);
    }
    
    public function getItemsAt(begin:Number, end:Number, dimension:String):Array
    {
      if(!(dimension in dimensions))
        return [];
      
      return Dimension(dimensions[dimension]).getItemsAt(begin, end);
    }
    
    public function clear():void
    {
      for(var name:String in dimensions)
      {
        if(!dimensions[name])
          continue;
        
        Dimension(dimensions[name]).clear();
        delete dimensions[name];
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