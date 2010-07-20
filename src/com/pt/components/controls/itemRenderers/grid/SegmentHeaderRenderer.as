package com.pt.components.controls.itemRenderers.grid
{
  import com.pt.components.controls.grid.DataGridSegment;
  import com.pt.components.controls.grid.events.HeaderResizeEvent;
  import com.pt.components.controls.grid.events.HeaderSortEvent;
  import com.pt.components.skins.SaneButtonSkin;
  
  import flash.display.DisplayObject;
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.events.Event;
  import flash.events.EventPhase;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  
  import mx.controls.Button;
  import mx.core.IDataRenderer;
  import mx.core.IFlexDisplayObject;
  import mx.core.IInvalidating;
  import mx.core.IUIComponent;
  import mx.core.UIComponent;
  import mx.styles.ISimpleStyleClient;

  public class SegmentHeaderRenderer extends UIComponent implements IDataRenderer
  {
    public function SegmentHeaderRenderer()
    {
      super();

      setStyle('cornerRadius', 0);

      setStyle('borderThickness', 0);
      setStyle('selectedBorderThickness', 0);

      setStyle('fillColors', [0xFFFFFF, 0xDDDDDD, 0xEEEEEE, 0xFFFFFF, 0xAAAAAA, 0xBBBBBB]);
      setStyle('selectedFillColors', [0xAAAAAA, 0xBBBBBB, 0xCCCCCC, 0xDDDDDD, 0x999999, 0xAAAAAA]);

      setStyle('fillAlphas', [1, 1]);
      setStyle('selectedFillAlphas', [1, 1]);

      percentWidth = 100;
      percentHeight = 100;

      addEventListener(MouseEvent.CLICK, onClick);
      addEventListener(MouseEvent.MOUSE_DOWN, onDown);
      addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    }

    private var changeSkin:Boolean = false;
    private var over:Boolean = false;

    private function onMouseOver(event:MouseEvent):void
    {
      if(event.eventPhase != EventPhase.AT_TARGET)
        return;

      over = true;
      changeSkin = true;
      invalidateDisplayList();
    }

    private function onMouseOut(event:MouseEvent):void
    {
      if(event.eventPhase != EventPhase.AT_TARGET)
        return;

      over = false;
      changeSkin = true;
      invalidateDisplayList();
    }

    private var down:Boolean = false;

    private function onDown(event:MouseEvent):void
    {
      if(event.eventPhase != EventPhase.AT_TARGET)
        return;

      down = true;
      changeSkin = true;
      invalidateDisplayList();
    }
    
    private var ascending:Boolean = false;

    private function onClick(event:MouseEvent):void
    {
      if(event.eventPhase != EventPhase.AT_TARGET)
        return;

      down = false;
      selected = true;
      ascending = !ascending;
      
      dispatchSortEvent(ascending)
    }

    private var _data:Object;

    public function get data():Object
    {
      return _data;
    }

    public function set data(value:Object):void
    {
      if(value === _data)
        return;

      _data = value;

      if(data && tf)
        tf.text = data.toString();

      invalidateDisplayList();
    }

    private var _segment:DataGridSegment;

    public function get segment():DataGridSegment
    {
      return _segment;
    }

    public function set segment(value:DataGridSegment):void
    {
      if(value === _segment)
        return;

      _segment = value;
      selected = segment.selected;
      handle.mouseEnabled = segment.resizable;
    }

    private var _selected:Boolean = false;

    public function get selected():Boolean
    {
      return _selected;
    }

    public function set selected(value:Boolean):void
    {
      if(value == _selected)
        return;

      if(segment)
        segment.selected = value;

      changeSkin = true;
      _selected = value;
      invalidateDisplayList();
    }

    protected var tf:TextField;
    protected var skin:IFlexDisplayObject;
    protected var handle:SegmentHeaderDragHandle;

    override protected function createChildren():void
    {
      super.createChildren();

      if(!skin)
      {
        skin = new SaneButtonSkin();
        if(skin is ISimpleStyleClient)
          ISimpleStyleClient(skin).styleName = this;
        super.addChild(DisplayObject(skin));
      }

      if(!tf)
      {
        tf = new TextField();
        tf.defaultTextFormat = new TextFormat(null, 14);
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        tf.mouseEnabled = false;
        super.addChild(tf);
      }

      if(!handle)
      {
        handle = new SegmentHeaderDragHandle();
        handle.addEventListener('dragStart', onDragStart);
        handle.addEventListener('dragComplete', onDragStop);
        super.addChild(handle);
      }
    }

    override protected function updateDisplayList(w:Number, h:Number):void
    {
      super.updateDisplayList(w, h);

      skin.setActualSize(w, h);

      if(draggingHandle)
        return;

      if(changeSkin)
      {
        skin.name = selected ? (down ? "selectedDownSkin" : (over ? "selectedOverSkin" : "selectedUpSkin")) : (down ? "downSkin" : (over ? "overSkin" : "upSkin"));

        if(skin is IInvalidating)
        {
          IInvalidating(skin).invalidateDisplayList();
          IInvalidating(skin).validateNow();
        }
      }

      changeSkin = false;

      tf.y = (h - tf.height) * .5;
      tf.x = (w - tf.width) * .5;

      var g:Graphics = graphics;
      g.clear();
      g.lineStyle(1, 0xCCCCCC);
      g.moveTo(0, 0);
      g.lineTo(w, 0);

      handle.x = w - 1;
      handle.y = 0;
      handle.width = 1;
      handle.height = h;
    }

    protected function dispatchSortEvent(asc:Boolean):void
    {
      dispatchEvent(new HeaderSortEvent(HeaderSortEvent.SORT, asc));
    }

    protected var draggingHandle:Boolean = false;

    protected function onDragStart(event:Event):void
    {
      var pt:Point = localToGlobal(new Point());

      handle.dragBounds = new Rectangle(pt.x + segment.minSize, pt.y, segment.maxSize - segment.minSize, 0);
      draggingHandle = true;
    }

    protected function onDragStop(event:Event):void
    {
      draggingHandle = false;

      var pt:Point = globalToLocal(new Point(handle.x, handle.y));
      handle.x = pt.x;
      handle.y = pt.y;

      segment.measuredSize = pt.x;

      dispatchEvent(new HeaderResizeEvent());
    }
  }
}

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Mouse;
import flash.ui.MouseCursor;

internal class SegmentHeaderDragHandle extends Sprite
{
  public function SegmentHeaderDragHandle()
  {
    super();

    addEventListener(MouseEvent.ROLL_OVER, onRollOver);
    addEventListener(MouseEvent.ROLL_OUT, onRollOut);
    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
  }

  private function onRollOver(event:MouseEvent):void
  {
    Mouse.cursor = MouseCursor.HAND;
  }

  private function onRollOut(event:MouseEvent):void
  {
    if(!event.buttonDown)
      Mouse.cursor = MouseCursor.ARROW;
  }

  private var dragParent:DisplayObjectContainer;

  private function onMouseDown(event:Event):void
  {
    stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    dispatchEvent(new Event('dragStart'));
    dragParent = parent;

    var pt:Point = localToGlobal(new Point(0, 0));

    stage.addChild(this);

    x = pt.x;
    y = pt.y;

    startDrag(false, dragBounds);
  }

  private function onMouseUp(event:Event):void
  {
    stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    dragParent.addChild(this);
    stopDrag();
    dispatchEvent(new Event('dragComplete'));
    Mouse.cursor = MouseCursor.ARROW;
  }

  public var dragBounds:Rectangle;

  protected var _width:Number = 0;

  override public function get width():Number
  {
    return _width;
  }

  override public function set width(value:Number):void
  {
    if(value === _width)
      return;

    _width = value;
    render();
  }

  protected var _height:Number = 0;

  override public function get height():Number
  {
    return _height;
  }

  override public function set height(value:Number):void
  {
    if(value === _height)
      return;

    _height = value;
    render();
  }

  private function render():void
  {
    var g:Graphics = graphics;
    g.clear();
    g.lineStyle(width, 0xCCCCCC);
    g.moveTo(0, 0);
    g.lineTo(0, height);

    g.lineStyle();
    g.beginFill(0x00, 0.0);
    g.drawRect(Math.max(width, 10) * -1, 0, Math.max(width * 2, 20), height);
  }
}
