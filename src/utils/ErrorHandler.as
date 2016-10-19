package utils
{
	

	/**
	 * @author Raju.M
	 */	
	public class ErrorHandler
	{
		public function ErrorHandler()
		{
		}
		
		public static function log(Objclass:Class , message:String, playerId:int=0):void
		{
			trace( Objclass +" : " + "Message = " + message);
			//WebServiceInterface.getInstance().sendErrorInfo("http://casinotest.mangogames.com/poker/logtrace",Objclass,message,playerId);
		}
		
		
		
		/**
		 * on fatalError 
		 * send message to the Server about fatalError
		 * then server will send you whole game and match Impls
		 * those will be handled by messageHandler.
		 */		
		public static function fatalError():void
		{
			
		}

		public static function debug():void
		{
			
		}
	}
}