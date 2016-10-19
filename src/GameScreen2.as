package
{
	import feathers.controls.Screen;
	
	public class GameScreen2 extends Screen
	{
		public function GameScreen2()
		{
			super();
		}
		
		private var _roomId:int;
		private var _index:int;
		
		public function setRoom(roomId:int, roomName:String, index:int):void
		{
			_roomId = roomId;
			//label = roomName;
			_index = index;
		}
		
		public function get roomId():int { return _roomId; }
		public function get index():int { return _index; }
	}
}