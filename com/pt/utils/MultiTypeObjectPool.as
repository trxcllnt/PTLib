package com.pt.utils
{
    import flash.utils.Dictionary;
    
    /**
    * Original author Shane McCartney, http://lostinactionscript.com
    */
    public class MultiTypeObjectPool
    {
        public var pools:Dictionary;
        private var disposed:Boolean = false;
        
        public function MultiTypeObjectPool(... types:Array)
        {
            pools = new Dictionary(true);
            var len:int = types.length;
            for(var i:int = 0; i < len; i++)
                add(types[i]);
        }
        
        public function has(Type:Class):Boolean
        {
            return (Type in pools);
        }
        
        public function add(Type:Class):void
        {
            pools[Type] = new ObjectPool(Type);
        }
        
        public function checkOut(Type:Class):*
        {
            return ObjectPool(pools[Type]).checkOut();
        }
        
        public function checkIn(item:Object):void
        {
            ObjectPool(pools[item.constructor]).checkIn(item);
        }
        
        public function empty():void
        {
            var pool:ObjectPool;
            
            for each(pool in pools)
                pool.empty();
        }
        
        public function dispose():void
        {
            if(disposed)
                return;
            
            disposed = true;
            
            var pool:ObjectPool;
            
            for each(pool in pools)
            {
                pool.dispose();
                delete pools[pool];
            }
            
            pools = null;
        }
    }
}
