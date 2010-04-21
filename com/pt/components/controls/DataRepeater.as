package com.pt.components.controls
{
  import com.pt.components.controls.dataClasses.RepeaterData;
  
  import flash.display.DisplayObject;
  
  import mx.core.IDataRenderer;
  import mx.core.IFactory;
  import mx.core.IInvalidating;
  import mx.core.IUIComponent;
  import mx.core.UIComponent;
  import mx.styles.ISimpleStyleClient;
  
  [Style(name="itemRendererStyleName", type="String")]
  
  public class DataRepeater extends UIComponent
  {
    public function DataRepeater()
    {
      super();
    }
    
    private var _horizontalScrollPosition:Number = -1;
    
    public function get horizontalScrollPosition():Number
    {
      return _horizontalScrollPosition;
    }
    
    public function set horizontalScrollPosition(value:Number):void
    {
      if(value === _horizontalScrollPosition)
        return;
      
      _horizontalScrollPosition = value;
      invalidateProperties();
      invalidateDisplayList();
    }
    
    private var _verticalScrollPosition:Number = -1;
    
    public function get verticalScrollPosition():Number
    {
      return _verticalScrollPosition;
    }
    
    public function set verticalScrollPosition(value:Number):void
    {
      if(value === _verticalScrollPosition)
        return;
      
      _verticalScrollPosition = value;
      invalidateProperties();
      invalidateDisplayList();
    }
    
    protected var dataProviderChanged:Boolean = false;
    
    private var _dataProvider:Object;
    
    public function get dataProvider():Object
    {
      return _dataProvider;
    }
    
    public function set dataProvider(value:Object):void
    {
      if(value === _dataProvider)
        return;
      
      _dataProvider = value;
      dataProviderChanged = true;
      
      invalidateProperties();
      invalidateSize();
      invalidateDisplayList();
    }
    
    private var itemRendererChanged:Boolean = false;
    private var itemRendererFactory:IFactory;
    private var renderers:Array;
    private var repeaterData:RepeaterData;
    
    public function set itemRenderer(factory:IFactory):void
    {
      if(factory == itemRendererFactory)
        return;
      
      itemRendererFactory = factory;
      itemRendererChanged = true;
      
      invalidateProperties();
      invalidateSize();
      invalidateDisplayList();
    }
    
    protected var prequeueLengthChanged:Boolean = false;
    private var _prequeueLength:Number = 1;
    
    public function get prequeueLength():int
    {
      return _prequeueLength;
    }
    
    public function set prequeueLength(value:int):void
    {
      if(value === _prequeueLength)
        return;
      
      _prequeueLength = value;
      invalidateSize();
      invalidateDisplayList();
    }
    
    override protected function createChildren():void
    {
      super.createChildren();
      
      renderers = [];
      repeaterData = new RepeaterData();
    }
    
    override protected function commitProperties():void
    {
      super.commitProperties();
      
      updateRenderers();
    }
    
    override protected function measure():void
    {
      var h:Number = measuredHeight;
      
      super.measure();
      
      measuredHeight = h;
      
      if(dataProviderChanged || (dataProvider && itemRendererChanged))
      {
        // Only do this when the data or itemRenderer changes. This is an incredibly
        // intensive operation, so change the data/renderers as little as possible.
        measureAllDataItems();
      }
    }
    
    private var _nextRendererScrollDelta:int = -1;
    private var _previousRendererScrollPosition:int = -1;
    
    protected function updateRenderers():void
    {
      var scrollDelta:int = verticalScrollPosition - _previousRendererScrollPosition;
      var update:Boolean = dataProviderChanged || itemRendererChanged || prequeueLengthChanged || scrollDelta < 0 || scrollDelta >= _nextRendererScrollDelta;
      if(!update)
        return;
      
      var minPosition:Number = verticalScrollPosition;
      var maxPosition:Number = verticalScrollPosition;
      if(unscaledHeight > 0)
        maxPosition += unscaledHeight;
      else if(getExplicitOrMeasuredHeight() > 0)
        maxPosition += getExplicitOrMeasuredHeight();
      else
        maxPosition = repeaterData.size;
      
      var items:Array = repeaterData.getItemsBetweenPositions(minPosition, maxPosition, prequeueLength);
      if(items.length == 0)
        items = dataProvider as Array;
      
      if(!items || items.length <= 0)
        return;
      
      var renderer:DisplayObject;
      var i:int = 0;
      var n:int = items.length;
      
      for(i = 0; i < n; i++)
      {
        if(i < renderers.length)
          renderer = renderers[i];
        else
        {
          renderers.push(renderer = itemRendererFactory.newInstance());
          if(renderer is ISimpleStyleClient)
            ISimpleStyleClient(renderer).styleName = getStyle("itemRendererStyleName");
        }
        
        if(!renderer.hasOwnProperty("data"))
          continue;
        
        if(!contains(renderer as DisplayObject))
          addChild(renderer as DisplayObject);
        
        renderer["data"] = items[i];
      }
      
      while(renderers.length > n)
      {
        removeChild(renderers.splice(renderers.length - 1, 1)[0]);
      }
    }
    
    override protected function updateDisplayList(w:Number, h:Number):void
    {
      var renderer:DisplayObject;
      
      var rendererOffset:Number = 0;
      var extraScrollHeight:Number = 0;
      var rendererHeights:Number = 0;
      
      var i:int = 0;
      var n:int = renderers.length;
      
      for(i = 0; i < n; i++)
      {
        renderer = renderers[i];
        
        if(!renderer.hasOwnProperty("data"))
          continue;
        
        if(i == 0)
        {
          var pos:int = repeaterData.getItemPosition(renderer["data"]);
          var len:int = repeaterData.getItemLength(renderer["data"]);
          
          _nextRendererScrollDelta = len;
          _previousRendererScrollPosition = pos;
          
          rendererOffset = (verticalScrollPosition - pos) % len || 0;
        }
        
        if(renderer is IUIComponent)
        {
          IUIComponent(renderer).setActualSize(w, IUIComponent(renderer).getExplicitOrMeasuredHeight());
          IUIComponent(renderer).move(0, rendererHeights - rendererOffset);
          rendererHeights += IUIComponent(renderer).getExplicitOrMeasuredHeight();
        }
        else
        {
          renderer.width = w;
          renderer.x = 0;
          renderer.y = rendererHeights - rendererOffset;
          rendererHeights += renderer.height;
        }
      }
      
      itemRendererChanged = false;
      prequeueLengthChanged = false;
      dataProviderChanged = false;
    }
    
    protected function measureAllDataItems():void
    {
      if(!itemRendererFactory)
        return;
      
      repeaterData.clear();
      
      measuredWidth = 0;
      measuredHeight = 0;
      
      var renderer:DisplayObject = itemRendererFactory.newInstance();
      
      if(renderer is ISimpleStyleClient)
        ISimpleStyleClient(renderer).styleName = getStyle("itemRendererStyleName");
      
      addChild(renderer);
      
      // Assume data is an Array, TODO: Update this to work with any collection.
      var a:Array = dataProvider as Array;
      var i:int = 0;
      var n:int = a.length;
      var rWidth:Number = 0;
      var rHeight:Number = 0;
      
      for(i = 0; i < n; i++)
      {
        if(renderer is IDataRenderer)
          IDataRenderer(renderer).data = a[i];
        
        if(renderer is IInvalidating)
          IInvalidating(renderer).validateNow();
        
        if(renderer is IUIComponent)
        {
          rWidth = IUIComponent(renderer).getExplicitOrMeasuredWidth();
          rHeight = IUIComponent(renderer).getExplicitOrMeasuredHeight();
        }
        else
        {
          rWidth = renderer.width;
          rHeight = renderer.height;
        }
        
        repeaterData.addItem(a[i], getRendererEnqueueLength(renderer));
        measuredWidth = Math.max(rWidth, measuredWidth);
        measuredHeight += rHeight;
      }
      
      if(renderer is ISimpleStyleClient)
        ISimpleStyleClient(renderer).styleName = null;
      
      if(renderer is IDataRenderer)
        IDataRenderer(renderer).data = null;
      
      removeChild(renderer);
      
      renderer = null;
    }
    
    protected function getRendererEnqueueLength(renderer:DisplayObject):int
    {
      if(renderer is IUIComponent)
        return IUIComponent(renderer).getExplicitOrMeasuredHeight();
      
      return renderer.height;
    }
  }
}