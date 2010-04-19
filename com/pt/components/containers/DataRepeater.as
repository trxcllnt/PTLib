package com.pt.components.containers
{
  import com.pt.components.containers.data.IItemRenderer;
  import com.pt.components.containers.data.RepeaterData;
  
  import flash.display.DisplayObject;
  import flash.geom.Rectangle;
  
  import mx.core.IFactory;
  import mx.core.IUIComponent;
  import mx.core.ScrollPolicy;
  import mx.core.mx_internal;
  import mx.styles.ISimpleStyleClient;
  
  use namespace mx_internal;
  
  [Style(name="itemRendererStyleName", type="String")]
  
  public class DataRepeater extends DataContainer
  {
    public function DataRepeater()
    {
      super();
      clipContent = false;
    }
    
    override public function get horizontalScrollPolicy():String
    {
      return ScrollPolicy.OFF;
    }
    
    override public function get verticalScrollPolicy():String
    {
      return ScrollPolicy.OFF;
    }
    
    private var scrollPositionChanged:Boolean = false;
    
    private var _horizontalScrollPosition:Number = -1;
    
    override public function get horizontalScrollPosition():Number
    {
      return _horizontalScrollPosition;
    }
    
    override public function set horizontalScrollPosition(value:Number):void
    {
      if(value === _horizontalScrollPosition)
        return;
      
      scrollPositionChanged = true;
      _horizontalScrollPosition = value;
      updateRenderers();
      invalidateDisplayList();
    }
    
    private var _verticalScrollPosition:Number = -1;
    
    override public function get verticalScrollPosition():Number
    {
      return _verticalScrollPosition;
    }
    
    override public function set verticalScrollPosition(value:Number):void
    {
      if(value === _verticalScrollPosition)
        return;
      
      scrollPositionChanged = true;
      _verticalScrollPosition = value;
      updateRenderers();
      invalidateDisplayList();
    }
    
    override public function set data(value:Object):void
    {
      super.data = value;
      
      if(dataChanged)
      {
        scrollPositionChanged = true;
        invalidateDisplayList();
      }
    }
    
    private var itemRendererFactory:IFactory;
    private var renderers:Array;
    private var repeaterData:RepeaterData;
    
    public function set itemRenderer(factory:IFactory):void
    {
      if(factory == itemRendererFactory)
        return;
      
      var needsDimensions:Boolean = (itemRendererFactory == null && data != null);
      itemRendererFactory = factory;
      
      if(needsDimensions)
      {
        dataChanged = true;
        invalidateProperties();
      }
      
      invalidateDisplayList();
    }
    
    private var _scrollWidth:Number = 0;
    
    public function get scrollWidth():Number
    {
      return _scrollWidth;
    }
    
    private var _scrollHeight:Number = 0;
    
    public function get scrollHeight():Number
    {
      return _scrollHeight;
    }
    
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
      scrollPositionChanged = true;
      invalidateProperties();
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
      
      if(dataChanged)
      {
        // Only do this when the data or itemRenderer changes. This is an incredibly
        // intensive operation, so change the data/renderers as little as possible.
        calculateScrollDimensions();
      }
      if(scrollPositionChanged)
      {
        updateRenderers();
      }
    }
    
    private var _nextRendererScrollDelta:int = 0;
    private var _previousRendererScrollPosition:int = 0;
    
    protected function updateRenderers():void
    {
      var scrollDelta:int = verticalScrollPosition - _previousRendererScrollPosition;
      if(scrollDelta > 0 && scrollDelta < _nextRendererScrollDelta)
        return;
      
      var items:Array = repeaterData.getItemsBetweenPositions(verticalScrollPosition, verticalScrollPosition + unscaledHeight, prequeueLength);
      
      if(!items || items.length <= 0)
        return;
      
      var renderer:IItemRenderer;
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
        
        if(!contains(renderer as DisplayObject))
          addChild(renderer as DisplayObject);
        
        renderer.data = items[i];
      }
      
      while(renderers.length > n)
      {
        removeChild(renderers.splice(renderers.length - 1, 1)[0]);
      }
    }
    
    override protected function updateDisplayList(w:Number, h:Number):void
    {
      var rect:Rectangle;
      var renderer:IItemRenderer;
      
      var rendererOffset:Number = 0;
      var extraScrollHeight:Number = 0;
      var rendererHeights:Number = 0;
      
      var i:int = 0;
      var n:int = renderers.length;
      
      for(i = 0; i < n; i++)
      {
        renderer = renderers[i];
        
        rect = renderer.getDimensions();
        
        if(i == 0)
        {
          var pos:int = repeaterData.getItemPosition(renderer.data);
          var len:int = repeaterData.getItemLength(renderer.data);
          
          _nextRendererScrollDelta = len;
          _previousRendererScrollPosition = pos;
          
          rendererOffset = (verticalScrollPosition - pos) % len || 0;
        }
        
        if(renderer is IUIComponent)
        {
          IUIComponent(renderer).setActualSize(w, rect.height);
          IUIComponent(renderer).move(0, rendererHeights - rendererOffset);
        }
        
        rendererHeights += rect.height;
      }
      
      scrollPositionChanged = false;
      dataChanged = false;
    }
    
    override protected function scrollChildren():void
    {
    };
    
    override mx_internal function getScrollableRect():Rectangle
    {
      return new Rectangle(0, 0, int.MAX_VALUE, int.MAX_VALUE);
    }
    
    override mx_internal function createContentPane():void
    {
      if(contentPane)
      {
        rawChildren.removeChild(contentPane);
        contentPane = null;
      }
      return;
    }
    
    protected function calculateScrollDimensions():void
    {
      if(!itemRendererFactory)
        return;
      
      repeaterData.clear();
      _scrollWidth = 0;
      _scrollHeight = 0;
      
      var rect:Rectangle;
      var renderer:IItemRenderer = itemRendererFactory.newInstance();
      if(renderer is ISimpleStyleClient)
        ISimpleStyleClient(renderer).styleName = getStyle("itemRendererStyleName");
      addChild(renderer as DisplayObject);
      
      // Assume data is an Array, TODO: Update this to work with any collection.
      var a:Array = data as Array;
      var i:int = 0;
      var n:int = a.length;
      
      for(i = 0; i < n; i++)
      {
        rect = renderer.getDimensions(a[i]);
        repeaterData.addItem(a[i], rect.height);
        _scrollWidth = Math.max(rect.width, _scrollWidth);
        _scrollHeight += rect.height;
      }
      
      removeChild(renderer as DisplayObject);
      renderer = null;
      rect = null;
    }
  }
}