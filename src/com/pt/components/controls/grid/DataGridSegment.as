package com.pt.components.controls.grid
{
    import com.pt.components.controls.grid.itemRenderers.DataGridHeaderRenderer;
    
    import de.polygonal.ds.sort.compare.compareStringCaseInSensitive;
    
    import flash.geom.Point;
    
    import mx.core.ClassFactory;
    import mx.core.IFactory;
    
    public class DataGridSegment
    {
        public function DataGridSegment():void
        {
            header = new ClassFactory(DataGridHeaderRenderer);
        }
        
        public var size:Number = 0;
        public var measuredSize:Number = 0;
        public var percentSize:Number = NaN;
        public var minSize:Number = 25;
        public var maxSize:Number = 1000;
        
        public function get relativeMinSize():Number
        {
          return minSize;
        }
        
        public function get relativeMeasuredSize():Number
        {
          return measuredSize;
        }
        
        public var resizable:Boolean = true;
        public var selected:Boolean = false;
        
        public function getRelativePosition():Point
        {
            var pt:Point = position.clone();
            var p:DataGridSegment = parent;
            while(p)
            {
                pt = pt.add(p.position);
                p = p.parent;
            }
            
            return pt;
        }
        
        protected var pos:Point = new Point();
        
        public function get position():Point
        {
            return pos;
        }
        
        public function set position(value:Point):void
        {
            if(value === pos)
                return;
            
            pos = value;
        }
        
        protected var _parent:DataGridSegmentGroup;
        
        public var parent:DataGridSegmentGroup;
        
        public var rendererField:String;
        public var headerField:String;
        
        public var titleFunction:Function;
        
        public var dataField:String;
        public var dataFunction:Function;
        
        public var sortField:String;
        public var sortFunction:Function;
        
        public var title:String;
        
        private var _header:IFactory;
        
        public function get header():IFactory
        {
            return _header;
        }
        
        public function set header(factory:IFactory):void
        {
            if(factory === _header)
                return;
            
            _header = factory;
        }
        
        private var item:IFactory;
        
        public function get renderer():IFactory
        {
            return item;
        }
        
        public function set renderer(factory:IFactory):void
        {
            if(factory === item)
                return;
            
            item = factory;
        }
        
        public function applyData(data:*):*
        {
            if(dataFunction != null)
                return dataFunction(data);
            
            if(data && dataField in data)
                return data[dataField];
            
            if(data)
                return data;
            
            return "";
        }
        
        public function applyTitle(data:*):*
        {
            if(titleFunction != null)
                return titleFunction(data);
            
            if(title)
                return title;
            
            return data;
        }
        
        public function applySort(dataProvider:Array, ascending:Boolean = false):Array
        {
          var source:Array = dataProvider.concat();
          var flags:uint =  ascending ? 0 : Array.DESCENDING;
          
          if(sortField != null)
          {
            sortFields = getParentDataFields();
            var a:Array = buildArrayToSort(source, sortFields);
            a.sort(nestedSortFunction, flags);
            
            if(sortFunction != null)
              a.sort(sortFunction, flags);
            
            var n:int = source.length;
            var temp:Array = a.concat();
            
            for(var i:int = 0; i < n; ++i)
            {
              if(temp.indexOf(source[i]) == -1)
                temp.push(source[i]);
            }
            
            source = temp;
          }
          else if(sortFunction != null)
            source.sort(sortFunction, flags);
          else
            source.sort(flags);
          
          return source;
        }
        
        public function getParentDataFields():Array
        {
          var fields:Array = [];
          var s:DataGridSegment = this;
          while(s)
          {
            fields.push(s.dataField);
            s = s.parent;
          }
          
          return fields;
        }
        
        protected function buildArrayToSort(source:Array, fields:Array):Array
        {
          var a:Array = [];
          var obj:*;
          var copy:Array;
          var n:int = source.length;
          var field:String;
          
          for(var i:int = 0; i < n; i++)
          {
            obj = source[i];
            copy = fields.concat();
            while(copy.length)
            {
              field = copy.pop();
              if(!(field in obj))
              {
                obj = null;
                break;
              }
              
              obj = obj[field];
            }
            
            if(obj)
              a.push(source[i]);
          }
          
          return a;
        }
        
        protected var sortFields:Array = [];
        
        protected function nestedSortFunction(a:*, b:*):int
        {
          var fields:Array = sortFields.concat();
          var field:String;
          
          while(fields.length)
          {
            field = fields.pop();
            if(field in a)
            {
              a = a[field];
              if(!a)
                return 1;
            }
            else
              return 1;
            
            if(field in b)
            {
              b = b[field];
              if(!b)
                return -1;
            }
            else
              return -1;
          }
          
          field = sortField;
          
          a = field ? a[field] : a;
          b = field ? b[field] : b;
          
          if(!a)
            return 1;
          
          if(!b)
            return -1;
          
          if(a is String && b is String)
            return compareStringCaseInSensitive(a, b);
          
          return a - b;
        }
    }
}