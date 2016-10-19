package chat
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	
	
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	
	import starling.display.Image;
	import starling.display.Sprite;
	/**
	 * 
	 * @author Raju Pedda.M
	 * 
	 */	
	public class ChatAndLogComponent extends Sprite
	{
		private var _currentRoomId:int;
		private var _minimized:Boolean;
		private var chatContainer:Sprite;
		private var _textInput:TextInput;
		private var _textArea:TextArea;
		
		public function ChatAndLogComponent()
		{
			super();
			init();
		}
		
		private function init():void
		{
			ProxySignals.getInstance().chatLogsRefreshSignal.add(onChatLogsRefresh);
			ProxySignals.getInstance().toggleChatWindowSignal.add(onToggleChatWindow);
			
			// Chat 
			chatContainer		= new Sprite();
			chatContainer.x		= 10;
			chatContainer.y		= 10;
			chatContainer.width	= 300;
			chatContainer.height= 130;
			addChild(chatContainer)
			
			var bgImg:Image		= new Image(MangoAssetManager.I.getTexture("msg_popup"));
			chatContainer.addChild(bgImg);
			
			_textArea = new TextArea();
			_textArea.width	= 275;
			_textArea.height = 120;
			chatContainer.addChild(_textArea);
			
			_textInput	= new TextInput();
			chatContainer.addChild(_textInput);
			
			
			
			// Log
			
		}
		
		private function onChatLogsRefresh(chatLogs:ChatLogs, roomId:int):void
		{
			if (!chatLogs)
				return;
			
			_textArea.text = "";
			//txtLogs.text = "";
			_textInput.text = chatLogs.text;
			//_textInput..cursorManager.currentCursorXOffset = _textInput.text.length;
			_textArea.text +=(chatLogs.chats);
			//txtLogs.appendText(chatLogs.logs);
			_currentRoomId = roomId;
			
			if (chatLogs.isMinimized)
				onToggleChatWindow(true, _currentRoomId);
			else
				onToggleChatWindow(false, _currentRoomId);
		}
		
		private function onToggleChatWindow(shouldMinimize:Boolean, roomId:int):void
		{
			if (roomId == _currentRoomId)
			{
				if (shouldMinimize)
					minimize();
				else
					maximize();
			}
			else
			{
				SFSInterface.getInstance().getGameRoom(roomId).chatLogs.isMinimized = shouldMinimize;
			}
		}
		
		private function toggleMinimize():void
		{
			_minimized = !_minimized;
			if (_minimized)
				minimize();
			else
				maximize();
		}
		
		private function minimize():void
		{
			if(SFSInterface.getInstance().getGameRoom(_currentRoomId))
				SFSInterface.getInstance().getGameRoom(_currentRoomId).chatLogs.isMinimized = true;
			
		/*	btnMinimize.label = "Chat/Log";
			btnMinimize.width = 80;
			btnMinimize.height = 20;
			btnMinimize.x = 5;
			btnMinimize.y = height - 25;*/
			//grpContainer.visible = false;
			_minimized = true;
		}
		
		private function maximize():void
		{
			if(SFSInterface.getInstance().getGameRoom(_currentRoomId))
				SFSInterface.getInstance().getGameRoom(_currentRoomId).chatLogs.isMinimized = false;
			
			/*btnMinimize.label = "-";
			btnMinimize.width = 30;
			btnMinimize.height = 20;
			btnMinimize.x = 220;
			btnMinimize.y = 23;*/
			//grpContainer.visible = true;
			_minimized = false;
		}
	}
}