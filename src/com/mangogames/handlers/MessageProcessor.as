/**
 * Singleton instance - keeps a map of messages against the handler objects.
 * This class is instantiated on app initialization. 
 * On initialization, it instantiates all the classes in package com.mangogames.poker.servermsgs.handlers
 * It also reads the functions in each handler class and creates a hashmap of function against the objects containing them.
 * 
 * It has a method invoke(msgname, params), which retrieves the object handling the function (msgname) and invokes the corresponding method on that object 
 * 
 */
package com.mangogames.handlers
{
	import flash.utils.Dictionary;
	
	import logger.Logger;
	
	import org.as3commons.reflect.Method;
	import org.as3commons.reflect.Type;
	
	/**
	 * @author Raju.M
	 */	
	public class MessageProcessor
	{
		private var _methdMap:Dictionary = new Dictionary();
		
		public function MessageProcessor()
		{
			init();
		}
		
		//Read all msg handler classes and keep a map of methods handled by each handler.
		private function init():void
		{
			//Read all the classes in the package com.mangogames.poker.servermsgs.handlers
			//Currently I'm hardcoding the class instantiation...should use reflection to read all classes eventually
			//1. create GameMsgsHandler
			initMsgHandler( new GameEntryHandler() );
			initMsgHandler( new MatchEntryHandler() );
			initMsgHandler( new MatchPlayHandler() );
		}
		
		/**
		 * It will register all handler classes and their methods
		 * @param msgHandler
		 */		
		private function initMsgHandler(msgHandler:*):void
		{
			
			var clsType:Type = Type.forInstance(msgHandler);
			
			var arrMethods:Array = clsType.methods;
			
			for each(var methd:Method in arrMethods)
			{
				var mthdName:String = methd.name;
				
				var declaredIn:String = methd.declaringType.name;
				
				if( declaredIn != "Object" )
				//store the methodname and the instance in a hashmap.
				    _methdMap[mthdName] = msgHandler;
			}
		}
		
		/**
		 * Invoke the message handler and process piggyback packet
		 */
		public function invoke(msgname:String, params:Object):int
		{
			Logger.log("invoking: " + msgname);
			
			//1. find the object that handles the msgname method
			var msgHandler:*  = _methdMap[msgname];
			if(msgHandler)
			{
				var clsType:Type  = Type.forInstance(msgHandler);
				
				var method:Method = clsType.getMethod(msgname);
				
				//2. invoke msgname function on that object, pass params.
				
				if( method != null )
				{
					method.invoke(msgHandler, [params]);
				}
				
				
				//3. Process piggyback message, if any
				var piggybackmthd:Method = clsType.getMethod("processPiggyback");
				
				if( piggybackmthd != null )
				{
					piggybackmthd.invoke(msgHandler, [params]);
				}
			}
			
			return 0;
		}
		
		public function dispose():void
		{
			
		}
	}
}