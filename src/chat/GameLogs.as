package chat
{
	public class GameLogs
	{
		public var logs:String;
		
		public function GameLogs()
		{
			dispose();
		}
		
		public function dispose():void
		{
			logs	= "";
		}
	}
}