package chat
{
	public class ChatLogs
	{
		public var chats:String;
		public var logs:String;
		public var isMinimized:Boolean = false;
		public var isSpectator:Boolean = false;
		public var text:String = "";
		public function ChatLogs()
		{
			dispose();
		}
		
		public function dispose():void
		{
			chats = "";
			logs = "";
		}
	}
}