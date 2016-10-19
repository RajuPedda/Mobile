package com.mangogames.services
{
	import com.mangogames.handlers.MessageProcessor;
	import com.mangogames.views.game.GameView;
	import com.smartfoxserver.v2.entities.SFSRoom;
	
	import chat.ChatLogs;
	import chat.GameLogs;
	
	/**
	 * 
	 * @author Raju Pedda.M
	 * 
	 */	
	public class GameRoom
	{
		private var _messageProcessor:MessageProcessor;
		private var _gameView:GameView;
		private var _chatLogs:ChatLogs;
		private var _gameLogs:GameLogs;
		
		
		public function GameRoom(room:SFSRoom)
		{
			_messageProcessor 	= new MessageProcessor();
			_gameView 			= new GameView(room);
			_chatLogs 			= new ChatLogs();
		 	_gameLogs			= new GameLogs();
		}
		
		public function dispose():void
		{
			if (_gameView.parent)
				_gameView.parent.removeChild(_gameView);
			
			_gameView.dispose();
			_messageProcessor.dispose();
			_chatLogs.dispose();
		}
		
		public function close(notify:Boolean):void
		{
			dispose();
			if (notify)
			{
				SFSInterface.getInstance().goToLobby(gameView.room);
			}
		}
		
		public function get messageProcessor():MessageProcessor { return _messageProcessor; }
		public function get gameView():GameView { return _gameView; }
		public function get chatLogs():ChatLogs { return _chatLogs; }
		public function get gameTrackLogs():GameLogs { return _gameLogs; }
	}
}