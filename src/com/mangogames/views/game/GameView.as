package com.mangogames.views.game
{
	import com.junkbyte.console.remote.ConsoleRe;
	import com.mangogames.audio.SoundDirector;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.AbstractBaseView;
	import com.mangogames.views.common.Hud;
	import com.mangogames.views.game.tableview.RummyTableView;
	import com.smartfoxserver.v2.entities.SFSRoom;
	
	import flash.ui.ContextMenu;
	
	import chat.ChatAndLogComponent;
	
	import feathers.controls.Button;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import utils.GameLogInfo;
	
	public class GameView extends Sprite
	{
		public var tableView:RummyTableView;
		
		private var _mediator:GameMediator;
		private var _room:SFSRoom;
		private var _gameStats:GameStatsView;
		private var console:ConsoleRe;
		private var _chatComponent:ChatAndLogComponent;
		
		public function GameView(room:SFSRoom)
		{
			super();
			
			_room = room;
			
			drawScreenElements();
			onEnterSound();
			var obj:Object	= AbstractBaseView.getStageSize();
			_gameStats = new GameStatsView();
			_gameStats.x	= room.groupId =="100" ? obj.stageWidth/4 :obj.stageWidth/7;
			_gameStats.y	= 0;
			addChild(_gameStats);
			_gameStats.setRoom(_room);
			
			_mediator = new GameMediator(this);
			new GameLogInfo();
		}
		
		override public function dispose():void
		{
			Hud.getInstance().detach();
			_mediator.dispose();
			super.dispose();
		}
		
		private function onEnterSound():void
		{
			SoundDirector.getInstance().initAllSounds();
		}		
		
		private function createTable():void
		{
			var custom_menu:ContextMenu = new ContextMenu();
			custom_menu.hideBuiltInItems();
			
			// table view
			tableView = new RummyTableView(this);
			addChild(tableView);
			//debuggConsole();
		}
		
		public function onRoomFocusChanged(index:int):void
		{
			tableView.adjustHighlighterForTabs(index);
		}
		
		private function debuggConsole():void
		{
			console = new ConsoleRe();
			
			Starling.current.nativeOverlay.addChild(console);
			
			console.visible	= true;
			console.commandLine = true;
			console.config.maxLines = 2000;
			console.config.maxRepeats = 200;
			console.config.commandLineAllowed = true;
			
			// Start remote service.
			console.remoter.remoting = true;
			// Disable scaling and moving
			console.panels.mainPanel.moveable = false;
			console.panels.mainPanel.scalable = false;
			
			console.addSlashCommand("disableLeaveTable", function ():void {
				tableView.onDisableLeaveBtn()
			});
		}
		
		private function drawScreenElements():void
		{
			/*_chatComponent		= new ChatAndLogComponent();
			_chatComponent.x	= 10;
			_chatComponent.y	= 450;
			addChild(_chatComponent);*/
			createTable();
			var btn:Button	= new Button();
			btn.x			= 100;
			btn.y			= 10;
			//addChild(btn);
			btn.addEventListener(Event.TRIGGERED, onLobbyClickHandler);
			Hud.getInstance().attachTo(this);
		}
		
		private function onLobbyClickHandler():void
		{
			ProxySignals.getInstance().viewLobbySignal.dispatch();
		}
		
		public function disableGameId():void
		{
			_gameStats.disableGameIdText();
		}
		
		public function setRound(round:String, roundCount:int=0):void
		{
			_gameStats.setRound(round, roundCount);
		}
		
		public function setPrizeMoney(amount:int):void
		{
			_gameStats.setPrizeMoney(amount);
		}
		
		public function hidePrizeMoney():void
		{
			_gameStats.hidePrizeMoney();
		}
		
		public function setGameDBId(dbId:Number):void
		{
			_gameStats.setGameDBId(dbId);
		}
		
		public function get room():SFSRoom { return _room; }
		
		// signals
		public var seatallottedSignal:Signal 			= new Signal();
		public var newplayerjoinedSignal:Signal 		= new Signal();
		public var gamemiddlejoinSignal:Signal 			= new Signal();
		public var myTableGameJoinSignal:Signal			= new Signal();
		public var reentrySignal:Signal 				= new Signal();
		public var playerleftSignal:Signal 				= new Signal();
		public var playergoneSignal:Signal 				= new Signal();
		public var playerdroppedSingnal:Signal 			= new Signal();
		public var turnoverSignal:Signal 				= new Signal();
		public var shuffleanddealSignal:Signal 			= new Signal();
		public var matchstartingSignal:Signal 			= new Signal();
		public var matchstartedSignal:Signal 			= new Signal();
		public var matchoverSignal:Signal 				= new Signal();
		public var matchsettlementSignal:Signal 		= new Signal();
		public var autosplitSignal:Signal 				= new Signal();
		public var playerpickedcardSignal:Signal 		= new Signal();
		public var newcardreceivedSignal:Signal 		= new Signal();
		public var discardedcardSignal:Signal 			= new Signal();
		public var pickerrorSignal:Signal 				= new Signal();
		public var startcountdownSignal:Signal 			= new Signal();
		public var stopcountdownSignal:Signal 			= new Signal();
		public var removeturntimerSignal:Signal 		= new Signal();
		public var buyinSignal:Signal 					= new Signal();
		public var buyinsuccessSignal:Signal 			= new Signal();
		public var buyinerrorSignal:Signal 				= new Signal();
		public var oppbuyinSignal:Signal 				= new Signal();
		public var updatewalletSignal:Signal 			= new Signal();
		public var showinitiatedSignal:Signal 			= new Signal();
		public var invalidshowSignal:Signal 			= new Signal();
		public var gameovershowcardsSignal:Signal 		= new Signal();
		public var gameoverSettlementSignal:Signal 		= new Signal();
		public var tolobbyongameexitSignal:Signal 		= new Signal();
		public var rejoinSignal:Signal 					= new Signal();
		public var rejoinrespSignal:Signal 				= new Signal();
		public var reshuffleSignal:Signal 				= new Signal();
		public var seatsuffleSignal:Signal 				= new Signal();
		public var manualSplitEnabled:Signal 			= new Signal();
		public var manualSplitAcceptedSignal:Signal 	= new Signal();
		public var manualSplitResultSignal:Signal 		= new Signal();
		public var admmsgSignal:Signal 					= new Signal();
		public var leaveTableDisableSignal:Signal 		= new Signal();
		public var leaveTableEnableSignal:Signal 		= new Signal();
		public var leaveTableResponseSignal:Signal 		= new Signal();
		public var cardsShownDoneSignal:Signal			= new Signal();
		public var rejoinSeatsuffleSignal:Signal 		= new Signal();
		public var onTimeOutSignal:Signal 				= new Signal();
		public var joinFailureOnRoomFullSignal:Signal	= new Signal();
		public var spectatorNotificationSignal:Signal	= new Signal();
		public var spectatorDealSignal:Signal			= new Signal();
		public var showDiscardsPopupSignal:Signal		= new Signal();
		
	}
}