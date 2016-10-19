package com.mangogames.signals
{
	import org.osflash.signals.Signal;
	
	public class ProxySignals
	{
		private static var _allowInstance:Boolean;
		private static var _instance:ProxySignals;
		
		public var baseInventoryCloseSignal:Signal;
		public var languageChangedSingal:Signal;
		
		public var SettingSelectedSignal:Signal;
		
		public var joinRoomRequestSignal:Signal;
		public var disconnectionSignal:Signal;
		public var loginSuccessfulSignal:Signal;
		public var loginFailureSignal:Signal;
		public var roomSelectedSignal:Signal;
		
		public var admmsgSignal:Signal;
		
		public var assetsreadySignal:Signal;
		public var screenTabChanged:Signal;
		public var gameRoomAdded:Signal;
		public var gameRoomRemoved:Signal;
		
		public var roomAddedSignal:Signal;
		public var roomRemovedSignal:Signal;
		public var roomVarUpdateSignal:Signal;
		public var userCountChangedSignal:Signal;
		public var roomJoinResultSignal:Signal;
		public var updateinventorySignal:Signal;
		public var userexitroomSignal:Signal;
		public var updateuseraccountSignal:Signal;
		public var sfsinvitationSignal:Signal;
		
		public var chatLogsRefreshSignal:Signal;
		public var LogTrackDataSignal:Signal;
		public var gameLogUpdatedSignal:Signal;
		
		public var gameLogTrackDataSignal:Signal;
		
		public var loggerSignal:Signal;
		public var toggleChatWindowSignal:Signal;
		public var updateInplaySignal:Signal;
		public var confirmationMsgSignal:Signal;
		public var tabHighlightIngSignal:Signal;
		public var refilledChipsSignal:Signal;
		public var logoutSignal:Signal;
		
		// to-do
		public var buyInFromLobbySignal:Signal;
		public var notifyRoomFullSignal:Signal;
		
		public var closeBrowserNotifySignal:Signal;
		public var playerLeftNotifierSignal:Signal;
		public var changeAspectRatioSignal:Signal;
		public var onLoadingDoneSignal:Signal;
		public var viewLobbySignal:Signal;
		
		public function ProxySignals()
		{
			if(!_allowInstance)
				throw new Error("Cannot create instance of singleton class GameProxySignals, use getInstance() instead");
			
			initSignals();
		}
		
		private function initSignals():void
		{
			languageChangedSingal			= new Signal();
			baseInventoryCloseSignal 		= new Signal();
			disconnectionSignal				= new Signal();
			loginSuccessfulSignal			= new Signal();
			loginFailureSignal				= new Signal();
			joinRoomRequestSignal			= new Signal();
			admmsgSignal  					= new Signal();
			SettingSelectedSignal			= new Signal();
			roomSelectedSignal				= new Signal();
			assetsreadySignal				= new Signal();
			screenTabChanged				= new Signal();
			gameRoomAdded					= new Signal();
			gameRoomRemoved					= new Signal();
			roomAddedSignal					= new Signal();
			roomRemovedSignal				= new Signal();
			roomVarUpdateSignal				= new Signal();
			userCountChangedSignal			= new Signal();
			roomJoinResultSignal			= new Signal();
			userexitroomSignal				= new Signal();
			sfsinvitationSignal				= new Signal();
			updateinventorySignal			= new Signal();
			updateuseraccountSignal			= new Signal(Number, int);
			chatLogsRefreshSignal			= new Signal();
			LogTrackDataSignal				= new Signal();
			gameLogUpdatedSignal			= new Signal();
			loggerSignal					= new Signal();
			toggleChatWindowSignal			= new Signal();	
			updateInplaySignal				= new Signal();
			confirmationMsgSignal			= new Signal();
			tabHighlightIngSignal			= new Signal();
			buyInFromLobbySignal			= new Signal(); 
			refilledChipsSignal				= new Signal();
			notifyRoomFullSignal			= new Signal();
			logoutSignal					= new Signal();
			closeBrowserNotifySignal		= new Signal();
			gameLogTrackDataSignal			= new Signal();
			playerLeftNotifierSignal		= new Signal();
			changeAspectRatioSignal			= new Signal();
			onLoadingDoneSignal				= new Signal();
			viewLobbySignal					= new Signal();
		}
		
		public static function getInstance():ProxySignals
		{
			if (!_instance)
			{
				_allowInstance = true;
				_instance = new ProxySignals();
				_allowInstance = false;
			}
			return _instance;
		}
	}
}