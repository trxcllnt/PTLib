package com.pt.utils
{
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    import flash.utils.IExternalizable;
    
    import mx.core.ClassFactory;
    
    public class ClonableClassFactory extends ClassFactory implements IExternalizable
    {
        public function ClonableClassFactory(generator:Class=null)
        {
            super(generator);
        }
        
        public function readExternal(data:IDataInput):void
        {
            this.generator = Class(data.readObject().constructor);
            this.properties = data.readObject();
        }
        
        public function writeExternal(data:IDataOutput):void
        {
            data.writeObject(new generator());
            data.writeObject(properties);
        }
    }
}