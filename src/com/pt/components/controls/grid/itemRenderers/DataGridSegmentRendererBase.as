package com.pt.components.controls.grid.itemRenderers
{
  import com.pt.components.controls.grid.DataGridSegment;
  import com.pt.components.controls.grid.DataGridSegmentGroup;
  import com.pt.components.controls.grid.itemRenderers.layout.DataGridSegmentRendererLayout;
  import com.pt.utils.MultiTypeObjectPool;

  import flash.display.DisplayObject;
  import flash.display.Graphics;

  import mx.core.ClassFactory;
  import mx.core.IDataRenderer;
  import mx.core.IFactory;
  import mx.core.UIComponent;

  public class DataGridSegmentRendererBase extends UIComponent implements IDataRenderer
  {
    public function DataGridSegmentRendererBase()
    {
      layout.target = this;
    }

    protected var layout:DataGridSegmentRendererLayout = new DataGridSegmentRendererLayout();

    protected static var pool:MultiTypeObjectPool = new MultiTypeObjectPool();

    private var _segments:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
    protected var segmentsChanged:Boolean = false;

    public function get segments():Vector.<DataGridSegment>
    {
      return _segments;
    }

    public function set segments(value:Vector.<DataGridSegment>):void
    {
      if(value === _segments)
        return;

      _segments = value;
      segmentsChanged = segments && segments.length > 0;

      if(segmentsChanged)
      {
        layout.segments = segments;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
      }
    }

    private var _data:Object;
    protected var dataChanged:Boolean = false;

    public function get data():Object
    {
      return _data;
    }

    public function set data(value:Object):void
    {
      if(value === _data)
        return;

      _data = value;
      dataChanged = data != null;

      if(dataChanged)
      {
        invalidateProperties();
      }
    }

    override protected function commitProperties():void
    {
      super.commitProperties();

      if((segmentsChanged) || (dataChanged && segments.length))
      {
        createSegmentRenderers();
        dataChanged = false;
      }
    }

    protected function createSegmentRenderers():void
    {
      var n:int = segments.length;
      var segment:DataGridSegment;
      var renderer:DisplayObject;

      for(var i:int = 0; i < n; ++i)
      {
        segment = segments[i];
        renderer = createSegmentRenderer(segment, i);

        if('segment' in renderer)
        {
          renderer['segment'] = segment;
        }

        if(segment is DataGridSegmentGroup && 'segments' in renderer)
        {
          renderer['segments'] = DataGridSegmentGroup(segment).children;
        }

        commitRendererData(renderer, segment);
      }
      while(numChildren > n)
      {
        pool.checkIn(removeChildAt(numChildren - 1));
      }
    }

    protected function createSegmentRenderer(segment:DataGridSegment, index:int):DisplayObject
    {
      return createRenderer(segment.renderer, index);
    }

    protected function createRenderer(factory:IFactory, index:int):DisplayObject
    {
      var type:Class;
      if(factory is ClassFactory)
        type = ClassFactory(factory).generator;
      else
        type = factory.newInstance()['constructor'];

      if(pool.has(type) == false)
        pool.add(type, factory);

      var renderer:DisplayObject = index < numChildren ? getChildAt(index) : DisplayObject(pool.checkOut(type));

      if((renderer is type) == false)
      {
        if(contains(renderer))
          pool.checkIn(removeChild(renderer));

        renderer = DisplayObject(pool.checkOut(type));
      }

      if(factory is ClassFactory)
      {
        var props:Object = ClassFactory(factory).properties;
        for(var prop:String in props)
          renderer[prop] = props[prop];
      }

      if(!contains(renderer))
        addChildAt(renderer, index);

      return renderer;
    }

    protected function commitRendererData(renderer:DisplayObject, segment:DataGridSegment):void
    {
      if(segment.rendererField in renderer)
      {
        renderer[segment.rendererField] = segment.applyData(data);
      }
      else if('data' in renderer)
      {
        renderer['data'] = segment.applyData(data);
      }
    }

    override protected function updateDisplayList(w:Number, h:Number):void
    {
      super.updateDisplayList(w, h);

      if(segmentsChanged)
        layout.updateDisplayList(w, h);

      segmentsChanged = false;
    }
  }
}