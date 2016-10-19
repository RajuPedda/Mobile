package utils
{
	import com.mangogames.signals.ProxySignals;
	
	import chat.GameLogs;

	public class GameLogInfo
	{
		private static var log:String;
		
		public function GameLogInfo()
		{
			ProxySignals.getInstance().LogTrackDataSignal.add(onLogTrackDataUpdated);
		}
		
		private function onLogTrackDataUpdated(chatLogs:GameLogs, roomId:int):void
		{
			log += chatLogs.logs;
		}
		
		public static function getUpdatedLog():String
		{
			return log;
		}
		
		public static function clear():void
		{
			log	= "";
		}
	}
}