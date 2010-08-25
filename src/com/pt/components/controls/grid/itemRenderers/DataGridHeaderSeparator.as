package com.pt.components.controls.grid.itemRenderers
{
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.InteractiveObject;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Rectangle;
  import flash.ui.Mouse;
  
  import mx.containers.BoxDirection;
  import mx.core.IFlexDisplayObject;
  import mx.core.UIComponent;

  [Style(name="horizontalCursor", type="Class")]
  [Style(name="verticalCursor", type="Class")]

  [Event(name="dragBegin", type="flash.events.Event")]
  [Event(name="dragComplete", type="flash.events.Event")]

  public class DataGridHeaderSeparator extends UIComponent
  {
    public function DataGridHeaderSeparator()
    {
      addEventListener(MouseEvent.ROLL_OVER, onRollOver);
      addEventListener(MouseEvent.ROLL_OUT, onRollOut);
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    public var dragBounds:Rectangle;

    private var cursor:IFlexDisplayObject;

    private function onRollOver(event:MouseEvent):void
    {
      if(dragging)
        return;

      var cursorClass:Class = getStyle(isV() ? 'verticalCursor' : 'horizontalCursor');
      if(!cursorClass || cursor)
        return;

      Mouse.hide();

      cursor = IFlexDisplayObject(new cursorClass());
      stage.addChild(DisplayObject(cursor));
      InteractiveObject(cursor).mouseEnabled = false;
      cursor.x = event.stageX;
      cursor.y = event.stageY;
    }
    
    private function onMouseMove(event:MouseEvent):void
    {
      if(!cursor)
        return;
      
      cursor.x = event.stageX;
      cursor.y = event.stageY;
    }

    private function onRollOut(event:MouseEvent):void
    {
      if(dragging)
        return;

      Mouse.show();
      
      destroyCursor();
    }
    
    private var originalParent:DisplayObjectContainer;

    private function onMouseDown(event:MouseEvent):void
    {
      dragging = true;
      invalidateDisplayList();
      
      dispatchEvent(new Event('dragBegin'));
      
      startDrag(false, dragBounds);
      
      addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    private function onMouseUp(event:MouseEvent):void
    {
      stopDrag();
      
      destroyCursor();
      
      Mouse.show();
      
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      
      removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      
      dragging = false;
      
      invalidateDisplayList();
      
      dispatchEvent(new Event('dragComplete'));
    }
    
    private function destroyCursor():void
    {
      if(cursor && stage.contains(DisplayObject(cursor)))
        stage.removeChild(DisplayObject(cursor));
      
      cursor = null;
    }

    private var _direction:String = BoxDirection.VERTICAL;

    [Inspectable(type="String", enumeration="vertical,horizontal")]

    public function get direction():String
    {
      return _direction;
    }

    public function set direction(value:String):void
    {
      if(value === _direction)
        return;

      _direction = value;

      invalidateDisplayList();
    }

    protected function isV():Boolean
    {
      return direction == BoxDirection.VERTICAL;
    }

    private var dragging:Boolean = false;

    override protected function updateDisplayList(w:Number, h:Number):void
    {
      super.updateDisplayList(w, h);

      var g:Graphics = graphics;
      g.clear();
      g.lineStyle(dragging ? 3 : 1, 0xCCCCCC);
      g.moveTo(0, 0);
      g.lineTo(isV() ? 0 : w, isV() ? h : 0);

      g.lineStyle();
      g.beginFill(0x00, 0);
      g.drawRect(isV() ? -3 : 0, isV() ? 0 : -3, isV() ? 3 : w, isV() ? h : 3);
    }
  }
}