package
{
	import feathers.controls.Screen;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	

	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	
	public class GameScreen1 extends Screen
	{
		public function GameScreen1()
		{
			trace("Game Screen");
		}
		
		private var _roomId:int;
		private var _index:int;
		private var _lobbyScreenSignal:Signal;
		
		override protected function initialize():void
		{
			super.initialize();
		}
		
		private function onLobbyClickHandler():void
		{
			dispatchEventWith("complete");
		}
		
		public function get lobbyScreenSignal():ISignal
		{
			return _lobbyScreenSignal;
		}
		
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