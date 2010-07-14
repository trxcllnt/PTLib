package com.pt.components.skins
{
  import flash.display.GradientType;
  
  import mx.core.IButton;
  import mx.core.UIComponent;
  import mx.skins.Border;
  import mx.styles.StyleManager;
  import mx.utils.ColorUtil;
  
  /**
   *  The skin for all the states of a Button.
   *
   *  @langversion 3.0
   *  @playerversion Flash 9
   *  @playerversion AIR 1.1
   *  @productversion Flex 3
   */
  public class SaneButtonSkin extends Border
  {
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function SaneButtonSkin()
    {
      super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  measuredWidth
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get measuredWidth():Number
    {
      return UIComponent.DEFAULT_MEASURED_MIN_WIDTH;
    }
    
    //----------------------------------
    //  measuredHeight
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get measuredHeight():Number
    {
      return UIComponent.DEFAULT_MEASURED_MIN_HEIGHT;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    private static var nameIndicies:Object =
      {
        upSkin:1,
        overSkin:3,
        downSkin:5,
        disabledSkin:7,
        selectedUpSkin:1,
        selectedOverSkin:3,
        selectedDownSkin:5,
        selectedDisabledSkin:7
      }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(w:Number, h:Number):void
    {
      super.updateDisplayList(w, h);
      
      calculateSkinValues();
      
      graphics.clear();
      
      draw(w, h);
    }
    
    protected var fillColors:Array;
    protected var fillAlphas:Array;
    protected var borderColors:Array;
    protected var borderAlphas:Array;
    protected var highlightColors:Array;
    protected var highlightAlphas:Array;
    protected var borderThickness:Number;
    protected var cr:Number;
    protected var cr1:Number;
    protected var cr2:Number;
    
    protected function calculateSkinValues():void
    {
      var index:int = nameIndicies[name] || 1;
      // User-defined styles.
      var cornerRadius:Number;
      var bThickness:Array;
      var bColors:Array;
      var bAlphas:Array;
      var fColors:Array;
      var fAlphas:Array;
      var hColors:Array;
      var hAlphas:Array;
      
      var emph:Boolean = false;
      
      if(parent is IButton)
        emph = IButton(parent).emphasized;
      
      if(name.toLowerCase().indexOf("selected") == -1)
      {
        //normal
        cornerRadius = getStyle("cornerRadius") || 0;
        bThickness = [].concat(getStyle("borderThickness") || [0]);
        bColors = [].concat(getStyle("borderColors") || [0xFFFFFF, 0xFFFFFF]);
        bAlphas = [].concat(getStyle("borderAlphas") || [1, 1]);
        fColors = [].concat(getStyle("fillColors") || [0xEEEEEE, 0xFFFFFF, 0xFFFFFF, 0xEEEEEE, 0xDDDDDD, 0xEEEEEE]);
        fAlphas = [].concat(getStyle("fillAlphas") || (1, 1));
        hColors = [].concat(getStyle("highlightColors") || [0xFFFFFF, 0xFFFFFF]);
        hAlphas = [].concat(getStyle("highlightAlphas") || [0.3, 0]);
      }
      else
      {
        //selected
        cornerRadius = getStyle("selectedCornerRadius") || 0;
        bThickness = [].concat(getStyle("selectedBorderThickness") || [0]);
        bColors = [].concat(getStyle("selectedBorderColors") || [0xFFFFFF, 0xFFFFFF]);
        bAlphas = [].concat(getStyle("selectedBorderAlphas") || [1, 1]);
        fColors = [].concat(getStyle("selectedFillColors") || [0xDDDDDD, 0xEEEEEE, 0xEEEEEE, 0xDDDDDD, 0xCCCCCC, 0xDDDDDD]);
        fAlphas = [].concat(getStyle("selectedFillAlphas") || [1, 1]);
        hColors = [].concat(getStyle("selectedHighlightColors") || [0xFFFFFF, 0xFFFFFF]);
        hAlphas = [].concat(getStyle("selectedHighlightAlphas") || [0.3, 0]);
      }
      
      var extractValues:Function = function(arr:Array, len:int = 2):Array
        {
          var a:Array = [];
          var i:int = arr.length > index ? index - 2 : -1;
          
          while(a.length < len)
            a.push(arr[++i]);
          
          return a;
        };
      
      fillColors = extractValues(fColors);
      fillAlphas = extractValues(fAlphas);
      borderColors = extractValues(bColors);
      borderAlphas = extractValues(bAlphas);
      highlightColors = extractValues(hColors);
      highlightAlphas = extractValues(hAlphas);
      borderThickness = extractValues(bThickness, 1);
      cr = Math.max(0, cornerRadius);
      cr1 = Math.max(0, cornerRadius - borderThickness);
      cr2 = Math.max(0, cornerRadius - borderThickness - 1);
    }
    
    protected function draw(w:Number, h:Number):void
    {
      // button border/edge
      if(borderThickness > 0)
      {
        drawRoundRect(0, 0, w, h, cr,
                      borderColors,
                      borderAlphas,
                      verticalGradientMatrix(0, 0, w, h),
                      GradientType.LINEAR, null,
                      {x:borderThickness, y:borderThickness, w:w - (borderThickness * 2), h:h - (borderThickness * 2), r:cr1});
      }
      
      // button fill
      drawRoundRect(borderThickness, borderThickness,
                    w - (borderThickness * 2),
                    h - (borderThickness * 2),
                    cr1, fillColors, fillAlphas,
                    verticalGradientMatrix(1, 1, w - 2, h - 2));
      
      // top highlight
      drawRoundRect(borderThickness, borderThickness,
                    w - (borderThickness * 2),
                    (h - (borderThickness * 2)) / 2,
                    {tl:cr2, tr:cr2, bl:0, br:0},
                    highlightColors, highlightAlphas,
                    verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2));
    }
  }
}
