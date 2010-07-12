package com.pt.utils
{
    import mx.core.IFactory;
    
    /**
     * Original author Shane McCartney, http://lostinactionscript.com
     * Modified to work with IFactory instances by Paul Taylor, http://guyinthechair.com
     */
    public class ObjectPool
    {
        
        public var minSize:int;
        public var size:int = 0;
        public var Create:IFactory;
        public var length:int = 0;
        
        private var list:Array = [];
        private var disposed:Boolean = false;
        
        public function ObjectPool(Create:IFactory, minSize:int = 10)
        {
            this.Create = Create;
            this.minSize = minSize;
            
            for(var i:int = 0; i < minSize; i++)
                add();
        }
        
        public function add():void
        {
            list[length++] = Create.newInstance();
            size++;
        }
        
        public function checkOut():*
        {
            if(length == 0)
            {
                size++;
                return Create.newInstance();
            }
            
            return list[--length];
        }
        
        public function checkIn(item:*):void
        {
            list[length++] = item;
        }
        
        public function empty():void
        {
            size = length = list.length = 0;
        }
        
        public function dispose():void
        {
            if(disposed)
                return;
            
            disposed = true;
            
            Create = null;
            list = null;
        }
    }
}
