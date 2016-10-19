package com.mangogames.views.game.tableview
{
	import com.junkbyte.console.Cc;
	import com.mangogames.audio.SoundDirector;
	import com.mangogames.events.HandCardIndicatorTouchedEvent;
	import com.mangogames.events.MenuEvent;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.models.IGame;
	import com.mangogames.models.UserInfo;
	import com.mangogames.rummy.model.impl.BestOfNGameImpl;
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.DealImpl;
	import com.mangogames.rummy.model.impl.DealPlayerImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.MatchImpl;
	import com.mangogames.rummy.model.impl.MatchPlayerImpl;
	import com.mangogames.rummy.model.impl.MatchSettlementImpl;
	import com.mangogames.rummy.model.impl.OpenDeckImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.PlayerSettlementImpl;
	import com.mangogames.rummy.model.impl.PointsGameImpl;
	import com.mangogames.rummy.model.impl.ScoreImpl;
	import com.mangogames.rummy.model.impl.SeatImpl;
	import com.mangogames.rummy.model.impl.SyndicateGameImpl;
	import com.mangogames.rummy.model.util.GameUtil;
	import com.mangogames.services.GameRoom;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.AbstractBaseView;
	import com.mangogames.views.game.AvatarsPopup;
	import com.mangogames.views.game.DealerCallout;
	import com.mangogames.views.game.GameRules;
	import com.mangogames.views.game.GameStatsView;
	import com.mangogames.views.game.GameView;
	import com.mangogames.views.popup.BuyInPopUp;
	import com.mangogames.views.popup.ConfirmationPopup;
	import com.mangogames.views.popup.RejoinPopup;
	import com.mangogames.views.popup.ReshufflePopup;
	import com.smartfoxserver.v2.entities.SFSRoom;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.variables.RoomVariable;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import feathers.controls.ToggleSwitch;
	import feathers.core.PopUpManager;
	
	import logger.Logger;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	
	import utils.Fonts;
	import utils.GameLogInfo;
	import utils.ScaleUtils;
	
	public class TableView extends Sprite
	{
		
		public function TableView(gameView:GameView)
		{
			super();
			init(gameView);
		}
		
		
		private const CARDS_TO_DEAL:int = 1;
		
		private var _countDownView:CountDownView;
		private var _dealerCallout:DealerCallout;
		private var _cardShuffleMachine:CardShuffleMachine;
		public var _seats:Vector.<SeatView>;
		public var _seatsDic:Dictionary;
		private var _lastTurnSeat:SeatView;
		private var _miscContainer:Sprite;
		private var _pointRummyTImer:Timer;
		private var _pointRummyTimerBackground:Image;
		private var _lblPointRummyTimer:TextField;
		private var _isDealerSet:Boolean = false;
		private var _dealerSymbol:Image;
		private var _isFirstTurn:Boolean = false;
		
		protected var _inGameHud:InGameHud;
		protected var _gameView:GameView;
		protected var _discardedCardView:DiscardedCardsView;
		
		protected var _gameImpl:IGame;
		protected var _matchImpl:MatchImpl;
		public var _mySeatId:int;
		protected var _dealImpl:DealImpl;
		protected var _handCardsImpl:HandCardsImpl;
		protected var _minBuyIn:int;
		protected var _settlement:MatchSettlementImpl;
		
		protected var _canDeclare:Boolean;
		protected var _isGamePaused:Boolean;
		protected var _isMatchOver:Boolean;
		protected var _isDropped:Boolean;
		
		protected var _isAutoDrop:Boolean = false; // for auto drop
		private var _history:Array; // for point rummy history 
		private var _historyGameId:Array; // for value of first round 
		public var _discardedCardButton:Button;
		private var _joker:CardImpl;
		
		private var _matchLeavePlayersCount:int;
		private var _isLeaveTable:Boolean;
		protected var _playersCount:int;
		protected var _playerLeftSeatId:int;
		private var _isMiddleJoin:Boolean;
		private var _beforeSeatAllotPopup:ConfirmationPopup;
		private var _isRejoinedSeatShuffle:Boolean;
		public var isShowInitiated:Boolean;
		private var _openCard:CardImpl;
		private var _isJoinedFromMyTable:Boolean;
		
		public var isShowProcessed:Boolean;
		public var _needToRunTurnTimer:Boolean;
		public var openDeckImpl:OpenDeckImpl;
		public var isForceShowBtnEnable:Boolean;
		public var isAlreadyPickedCard:Boolean;
		public var isMyTablePlayerDropped:Boolean;
		private var _isPlayerDropped:Boolean;
		private var _isReEntry:Boolean;
		private var _reEntryPlayerId:int;
		private var _reEntrySeatId:int;
		protected var isRandomizerDone:Boolean;
		public var isSpectator:Boolean;
		public var _settlementPopup:SettlementPopup;
		public var currentGameId:String;
		public var lastGameId:String;
		private var _msgBg:Image;
		public var WIDTH:int;
		public var HEIGHT:int;
		
		private function init(gameView:GameView):void
		{
			_gameView 		= gameView;
			_history 		= new Array();
			_historyGameId 	= new Array();
			var obj:Object	= AbstractBaseView.getStageSize();
			WIDTH			= obj.stageWidth;
			HEIGHT			= obj.stageHeight;
			
			initBg();
			initSignals();
			initDealer();
			initSeats();
			addEventListener(TouchEvent.TOUCH, onTouch);
			showMessage("We are arranging a seat for you");
		}
		
		private function initSignals():void
		{
			// adding listerners for the Signals
			_gameView.seatallottedSignal.add(onSeatAllotted);// changing
			_gameView.newplayerjoinedSignal.add(onPlayerJoined);
			_gameView.gamemiddlejoinSignal.add(onMiddleJoin);
			_gameView.myTableGameJoinSignal.add(myTableJoin);
			_gameView.rejoinSignal.add(onRejoin);
			_gameView.rejoinrespSignal.add(onRejoinResp);
			_gameView.playerleftSignal.add(onPlayerLeft);
			_gameView.playergoneSignal.add(onPlayerGone);
			_gameView.playerdroppedSingnal.add(onPlayerDropped);
			_gameView.buyinSignal.add(onBuyIn);
			_gameView.buyinsuccessSignal.add(onBuyInSuccess);
			_gameView.buyinerrorSignal.add(onBuyInError);
			_gameView.oppbuyinSignal.add(onOppBuyIn);
			_gameView.updatewalletSignal.add(onUpdateWallet);
			_gameView.startcountdownSignal.add(onStartCountDown);
			_gameView.stopcountdownSignal.add(onStopCountDown);
			_gameView.shuffleanddealSignal.add(onShuffleAndDeal);
			_gameView.reshuffleSignal.add(onReshuffle);
			_gameView.matchstartingSignal.add(onMatchStarting);
			_gameView.matchstartedSignal.add(onMatchStarted);
			_gameView.turnoverSignal.add(onTurnOver);
			_gameView.showinitiatedSignal.add(onShowInitiated);
			_gameView.invalidshowSignal.add(onInvalidShow);
			_gameView.gameovershowcardsSignal.add(onShowCards);
			_gameView.gameoverSettlementSignal.add(showSettlementBoardForDroppedPlayers);
			_gameView.matchsettlementSignal.add(onMatchSettlement);
			_gameView.autosplitSignal.add(onAutoSplit);
			_gameView.matchoverSignal.add(onMatchOver);
			_gameView.tolobbyongameexitSignal.add(onToLobbyOnGameExit);
			_gameView.seatsuffleSignal.add(onSeatShuffle);
			_gameView.admmsgSignal.add(onAdmMsg);
			_gameView.manualSplitEnabled.add(onManualSplitEnabled);
			_gameView.manualSplitAcceptedSignal.add(onManualSplitAccepted);
			_gameView.manualSplitResultSignal.add(onManualSplitResult);
			_gameView.leaveTableDisableSignal.add(onDisableLeaveBtn);
			_gameView.leaveTableEnableSignal.add(onEnableLeaveBtn);
			_gameView.leaveTableResponseSignal.add(onLeaveTableResponse);
			_gameView.cardsShownDoneSignal.add(onCardsShownDone);
			_gameView.reentrySignal.add(onUserJoinOnTheSameRoom);// re-entry
			_gameView.rejoinSeatsuffleSignal.add(onRejoinSeatShuffle);
			_gameView.showDiscardsPopupSignal.add(showDiscardsPopup);
			_gameView.joinFailureOnRoomFullSignal.add(joinFailOnRoomFull);
			ProxySignals.getInstance().logoutSignal.add(onLogout);
			_gameView.spectatorNotificationSignal.add(onSpectatorJoin);
			_gameView.spectatorDealSignal.add(onSpectatorsDeal);
			ProxySignals.getInstance().gameRoomAdded.add(onRoomAdded);
			ProxySignals.getInstance().gameRoomRemoved.add(onRoomRomoved);
			ProxySignals.getInstance().disconnectionSignal.add(onDisconnected);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			var settingsClick:Touch	= event.getTouch(settingsBtn);
			var isSettingsClicked:Boolean	= false;
			
			if(settingsClick)
			{
				if (touch.phase == TouchPhase.ENDED)
				{
					isSettingsClicked	= true;
				}
			}
			if (touch)
			{
				if (touch.phase == TouchPhase.ENDED)
				{
					if(!isSettingsClicked && _gameSettings)	_gameSettings.visible	= false;
					
					
				}
			}
			
		}
		// overrided in RummyTablesView
		protected function showDiscardsPopup():void
		{
		}
		
		private var _highligheter:Image;
		private var _gameRulesPopup:GameRules;
		private var _avatarBtn:Button;
		private var settingsBtn:Button;
		private var _avatarPopup:AvatarsPopup;
		private var _isAvatarBtnShowing:Boolean;
		private var _settingsContainer:Sprite;
		private var _btnLeave:Button;
		private var _leavePopup:ConfirmationPopup;
		private var _soundToggleBtn:ToggleSwitch;
		private var _gameSettings:GameSettings;
		
		
		private function onRoomAdded(roomId:int, roomName:String):void		
		{
			// comment this for Mobile
			/*if(_highligheter == null)
			{
				_highligheter	= new Image(MangoAssetManager.I.getTexture("notification_01"));
				addChild(_highligheter);
			}*/
			//adjustHighlighterForTabs();
		}
		
		private function onDisconnected(disconnected:Boolean):void
		{
			var imgName:String	= disconnected?"network_off":"network_on";
			var network_icon:Image	= new Image(MangoAssetManager.I.getTexture(imgName));
			network_icon.x	= 0;
			network_icon.y	= 10;
			addChild(network_icon);
			
		}
		
		public function adjustHighlighterForTabs(index:int=0):void
		{
			if(index>0)
			{
				if(index ==1)
				{
					_highligheter.x	= 122;
					_highligheter.y	= Constants.TARGET_HEIGHT-37;
				}
				else
				{
					_highligheter.x	= 187;
					_highligheter.y	= Constants.TARGET_HEIGHT-37;
				}
			}
			else
			{
				if(SFSInterface.getInstance().GameRooms.length == 1)
				{
					_highligheter.x	= 122;
					_highligheter.y	= Constants.TARGET_HEIGHT-37;
				}
				else
				{
					_highligheter.x	= 187;
					_highligheter.y	= Constants.TARGET_HEIGHT-37;
				}
			}
		}
		
		private function onRoomRomoved(roomId:int):void
		{
			// comment this for Mobile
			//adjustHighlighterForTabs();
		}
		
		private function onLogout():void
		{
			SFSInterface.getInstance().leaveTableCount ++;
			
			if(isPlayerIncludedInTheCurrentMatch())
			{
				SFSInterface.getInstance().dropMe(_gameView.room, true, _inGameHud._isPlayerDropped);
			}
			else
			{
				dispose();
				cleanup();
				SFSInterface.getInstance().closeRoom(_gameView.room.id, true);
			}
			
			//SFSInterface.getInstance().goToLobby(_gameView.room);
			
			if(SFSInterface.getInstance().leaveTableCount == SFSInterface.getInstance().GameRooms.length)
			{
				Starling.juggler.delayCall(logOut, 1);
				
				function logOut():void
				{
					SFSInterface.getInstance().logOutRequest();
				}
			}
			
		}
		
		private function onSpectatorsDeal(deal:DealImpl, displayId:String, roundCount:int):void
		{
			currentGameId			= displayId;
			isSpectator	= true;
			_isDealerSet	= false;
			SFSInterface.getInstance().getGameRoom(_gameView.room.id).chatLogs.isSpectator = true;	
			
			_dealImpl	= deal;
			_gameView.setRound(displayId, roundCount);
			
			if (gameImpl && (gameImpl is SyndicateGameImpl || gameImpl is BestOfNGameImpl))
				_gameView.setPrizeMoney(_dealImpl.gameprize);
			
			onCardsDealComplete(null, true);
			if(_gameImpl is PointsGameImpl)
				showGamestartTimer();
		}
		
		private function isPlayerIncludedInTheCurrentMatch():Boolean
		{
			var isIncluded:Boolean = false;
			
			if(_matchImpl)
			{
				var myPlayerId:int	= SFSInterface.getInstance().userInfo.id;
				var matchPlayer:MatchPlayerImpl;
				var len:int	= _matchImpl.matchplayer.length;
				
				for(var i:int=0; i<len; i++)
				{
					matchPlayer	= _matchImpl.matchplayer[i];
					// this will act as LeaveTable request if user joined the room
					if(matchPlayer && matchPlayer.dbId == myPlayerId)
					{
						return isIncluded = true;
					}
				}
			}
			return isIncluded;
		}
		
		private function initBg():void
		{
			// table bg
			var imgTable:Image = new Image(MangoAssetManager.I.getTexture("game_bg"));
			ScaleUtils.applyPercentageScale(imgTable, 100, 100);
			addChild(imgTable);
			
			var help_btn:Button	= new Button(MangoAssetManager.I.getTexture("help_btn"));
			help_btn.x	= 50;
			help_btn.y	= 5;
			//addChild(help_btn);
			help_btn.addEventListener(Event.TRIGGERED, function ():void{ navigateToURL(new URLRequest(Constants.TARGET_WEBSITE + "/help.html"), "_blank");})
			
			var network_icon:Image	= new Image(MangoAssetManager.I.getTexture("network_on"));
			network_icon.x	= 5;
			network_icon.y	= 10;
			addChild(network_icon);
		
			settingsBtn		= new Button(MangoAssetManager.I.getTexture("settings_btn"));
			settingsBtn.x	= WIDTH-100;
			settingsBtn.y	= 10;
			addChild(settingsBtn);
			settingsBtn.width = settingsBtn.width/2;
			settingsBtn.height	= settingsBtn.height/2;
			settingsBtn.addEventListener(Event.TRIGGERED, onSettingsBtnClick);
			
			var inviteBtn:Button	= new Button(MangoAssetManager.I.getTexture("refer&earn_btn"));
			inviteBtn.x	= WIDTH-inviteBtn.width-10;
			inviteBtn.y	= 10;
			addChild(inviteBtn);
			inviteBtn.addEventListener(Event.TRIGGERED, function ():void{ navigateToURL(new URLRequest(Constants.TARGET_WEBSITE + "/referNow.html"), "_blank");})
			
			var realOrFun:int = _gameView.room.getVariable("RealOrFun").getIntValue();
			if(realOrFun ==0)
			{
				var playWithBtn:Button	= new Button(MangoAssetManager.I.getTexture("playwithrealchips_btn"));
				playWithBtn.x	= (WIDTH-playWithBtn.width)/2;
				playWithBtn.y	= 0;
				addChild(playWithBtn);
			}
			// commented this for Mobile
			/*var gameRules:Button	= new Button(MangoAssetManager.I.getTexture("gamerules_btn"));
			gameRules.x	= 185;
			gameRules.y	= 10;
			//addChild(gameRules);
			gameRules.addEventListener(Event.TRIGGERED, onGameRulesBtnClick)*/
			
			Starling.current.nativeStage.stage.addEventListener("rightClick", onRightClick);
		}
		
		private function onSettingsBtnClick():void
		{
			if(_gameSettings)
			{
				_gameSettings.visible	= _gameSettings.visible?false:true;
			}
			else
			{
				_gameSettings			= new GameSettings(this, onLeaveTable);
				_gameSettings.x			= settingsBtn.x;
				_gameSettings.y			= settingsBtn.y;
				_gameSettings.visible	= true;
				gameView.addChild(_gameSettings);
			}
		}
		
		private function onLeaveTable(event:Event):void
		{
			var message:String = "Do you really want to leave this table?";
			PopUpManager.root = gameView;
			_leavePopup		  = new ConfirmationPopup("LEAVE TABLE", message, onOk, onCancel);
			PopUpManager.addPopUp(_leavePopup);
			
			function onOk():void
			{
				if(isMiddleJoin || isSpectator)
				{
					tableCleanUp();
				}
				else if(matchImpl)
				{
					if((gameImpl is BestOfNGameImpl) && playersCount==1) 
						tableCleanUp();
					else
						SFSInterface.getInstance().dropMe(gameView.room, true, _isPlayerDropped);
				}
				else
				{
					tableCleanUp();
				}
			}
			
			function onCancel():void
			{
				// nothing to do here
				_gameSettings.visible	= _gameSettings.visible?false:true;
			}
		}
		
		// cleanup
		private function tableCleanUp():void
		{
			var room:SFSRoom = gameView.room;
			dispose();
			cleanup();
			SFSInterface.getInstance().closeRoom(gameView.room.id, true);
		}
		
		private function onAvatarsBtnClick():void
		{
			_avatarPopup	= new AvatarsPopup(onAvatarPopupClosed);
			PopUpManager.addPopUp(_avatarPopup);
		}
		
		private function onAvatarPopupClosed(isSelected:Boolean):void
		{
			if(isSelected)
			{
				var seatVw:SeatView			= getSeatBySeatId(_mySeatId);
				seatVw.initAvatar(SFSInterface.getInstance().userInfo.avatarId);
			}
			_settingsContainer.visible	= _settingsContainer.visible?false:true;
		}
		
		private function onGameRulesBtnClick(event:Event):void
		{
			trace(event);
			trace(_gameImpl);
			_gameRulesPopup	= new GameRules(_gameImpl, onGameRulesClose, _gameView);
			PopUpManager.addPopUp(_gameRulesPopup);
			
		}
		
		private function onGameRulesClose():void
		{
			PopUpManager.removePopUp(_gameRulesPopup)
		}
		
		// Don't show anything on right click
		protected function onRightClick(event:MouseEvent):void
		{
		
		}
		
		private function initDealer():void
		{
			var dealerView:DealerView = new DealerView();
			addChild(dealerView);
			dealerView.x = (WIDTH - dealerView.width) / 2;
			dealerView.y = (HEIGHT - dealerView.height) / 2;
			
			// assign dealer callouts
			_dealerCallout = new DealerCallout(dealerView);
			addChild(_dealerCallout);
			
			// add the shuffle machine near dealer
			_cardShuffleMachine = new CardShuffleMachine(this);
			addChild(_cardShuffleMachine);
			_cardShuffleMachine.x = dealerView.x + dealerView.width / 2 - _cardShuffleMachine.width / 2;
			_cardShuffleMachine.y = dealerView.y + dealerView.height;
			_cardShuffleMachine.init();
		}
		
		private function initSeats():void
		{
			_seats = new Vector.<SeatView>(_gameView.room.maxUsers);
			_seats.fixed = true;
			
			_seatsDic	= new Dictionary(true);
			for (var i:int = 0; i < _gameView.room.maxUsers; i++)
			{
				// for 2 players table
				// this will create opponent seatView
				if (_gameView.room.maxUsers == 2 && i == 1)
				{
					var opponentSeatView:SeatView = new SeatView(3);  
					addChild(opponentSeatView);
					opponentSeatView.initEmptySeat(); // start with empty seats
					opponentSeatView.initHandCards(this);
					_seats[i] = opponentSeatView;
					_seatsDic[i]	= opponentSeatView;
				}
				else
				{
					// for 6 players table 
					// this will create our seat and opponent seats
					var seatView:SeatView = new SeatView(i);
					addChild(seatView);
					seatView.initEmptySeat(); // start with empty seats
					seatView.initHandCards(this);
					_seats[i] = seatView;
					_seatsDic[i]	= seatView;
				}
			}
			
			// Commented as reposition not working after adding seat view
//			if (_gameView.room.maxUsers == 2)
//			{
//				_seats[1].reposition(3);
//				seatView.initHandCards(this);
//			}
			
			_miscContainer = new Sprite();
			addChild(_miscContainer);
		}
		
		override public function dispose():void
		{
			if (mySeat)
				mySeat.addEventListener(HandCardIndicatorTouchedEvent.HAND_CARDS_TOUCHED, onHandCardsTouched);
			
			_inGameHud.removeFromParent(true);
			
			_gameView.seatallottedSignal.removeAll();
			_gameView.newplayerjoinedSignal.removeAll();
			_gameView.gamemiddlejoinSignal.removeAll();
			_gameView.myTableGameJoinSignal.removeAll();
			_gameView.rejoinSignal.removeAll();
			_gameView.playerleftSignal.removeAll();
			_gameView.playergoneSignal.removeAll();
			_gameView.playerdroppedSingnal.removeAll();
			_gameView.buyinSignal.removeAll();
			_gameView.buyinsuccessSignal.removeAll();
			_gameView.oppbuyinSignal.removeAll();
			_gameView.updatewalletSignal.removeAll();
			_gameView.startcountdownSignal.removeAll();
			_gameView.stopcountdownSignal.removeAll();
			_gameView.shuffleanddealSignal.removeAll();
			_gameView.reshuffleSignal.removeAll();
			_gameView.matchstartingSignal.removeAll();
			_gameView.matchstartedSignal.removeAll();
			_gameView.turnoverSignal.removeAll();
			_gameView.showinitiatedSignal.removeAll();
			_gameView.invalidshowSignal.removeAll();
			_gameView.gameovershowcardsSignal.removeAll();
			_gameView.matchsettlementSignal.removeAll();
			_gameView.autosplitSignal.removeAll();
			_gameView.matchoverSignal.removeAll();
			_gameView.tolobbyongameexitSignal.removeAll();
			_gameView.seatsuffleSignal.removeAll();
			_gameView.admmsgSignal.removeAll();
			_gameView.manualSplitEnabled.removeAll();
			_gameView.manualSplitAcceptedSignal.removeAll();
			_gameView.manualSplitResultSignal.removeAll();
			_gameView.leaveTableDisableSignal.removeAll();
			_gameView.leaveTableEnableSignal.removeAll();
			_gameView.leaveTableResponseSignal.removeAll();
			_gameView.cardsShownDoneSignal.removeAll();
			_gameView.reentrySignal.removeAll();
			_gameView.rejoinSeatsuffleSignal.removeAll();
			ProxySignals.getInstance().logoutSignal.removeAll();
			
			_dealerCallout.cleanUp();
			
			// ui cleanup 
			_lastTurnSeat = null;
			for (var i:int = 0; i < _gameView.room.maxUsers; i++)
			{
				var seatView:SeatView = getSeatBySeatId(i);
				if (seatView)
				{
					seatView.dispose();
					seatView = null;
				}
			}
			super.dispose();
		}
		
		private function onSeatAllotted(gameImpl:IGame, seatId:int, minBuyIn:int, player:PlayerImpl, seatImpl:SeatImpl=null):void
		{
			removeMessage();
			Logger.log("Seatallotted SeatId: " + seatId);
			_gameImpl = gameImpl;
			_mySeatId = seatId;
			_minBuyIn = minBuyIn;
			var tempPlayer:PlayerImpl;
			var isEligibleToSit:Boolean;
			
			if (!(gameImpl is PointsGameImpl))
				_gameView.setGameDBId(gameImpl.dbId);
			
			// we make seating arrangement for every one.
			// make sure that I seat at the center
			// my current seat position provided is "seatId"
			for (var i:int = 0; i < gameImpl.seat.length; i++)
			{
				var seatImpl:SeatImpl 	= gameImpl.seat[i];
				tempPlayer				= seatImpl.player;
				isEligibleToSit			= true;
				// allocating the seat , if player included in the current match 
				// playerState = 3 - kicked out from the last match
				// playerState = 4 - left from the match
				if(tempPlayer && tempPlayer.state == 4 && !getIsMyTableRoom(tempPlayer.id))// player kicked 
				{
					isEligibleToSit	= false;
				}
				if(tempPlayer && tempPlayer.state == 3)// player kicked 
				{
					isEligibleToSit	= false;
				}
				if(isEligibleToSit)
				{
					var relSeatPos:int = GameUtil.getRelativeSeatPosition(seatImpl.seatId, _mySeatId, _gameImpl.seat.length);
					_seats[relSeatPos].seatPlayer(seatImpl, (_gameImpl is PointsGameImpl), -1, seatImpl.player);
				}
//				if (seatImpl.player)
//					_discardedCardView.addTabFor(seatImpl.player.name);
			}
			if(player)
				updateWallet(player.id, player.wallet);
			
			SFSInterface.getInstance().notifyGameStart(_gameView.room);
			// also, listen to my hand card touced events
			if(mySeat)
				mySeat.addEventListener(HandCardIndicatorTouchedEvent.HAND_CARDS_TOUCHED, onHandCardsTouched);
			
			// point me 
			//if (!_isJoinedFromMyTable && !isSpectator)
				//pointMeOut();
		}
		
		private function getIsMyTableRoom(currentPlayerId:int):Boolean
		{
			var sfsRoom:SFSRoom		= _gameView.room;
			var roomVar:RoomVariable = sfsRoom.getVariable("isleavetableArray");
			if(!roomVar)
				return true;
			
			var playersList:SFSArray	= SFSArray(roomVar.getSFSArrayValue());
			var len:int					= playersList?playersList.size():0;
			var playerObj:ISFSObject;
			var isLeaveTable:Boolean;
			var playerId:Number;
			
			for( var i:int=0; i<len; i++)
			{
				playerObj	= playersList.getSFSObject(i);
				playerId	= playerObj.getLong("playerid");
				if(currentPlayerId == playerId)
				{
					isLeaveTable	= playerObj.getBool("isleavetable");
					if(!isLeaveTable)
					{
						return true;
					}
				}
				
			}
			return false;
		}
		
		
		protected function onHandCardsTouched(event:HandCardIndicatorTouchedEvent):void
		{
			// nothing to do here
		}
		
		// on User re-entry
		// activated to opponents players
		private function onUserJoinOnTheSameRoom(playerId:int, seatId:int, amount:int):void
		{
			_isReEntry				= true;
			_reEntryPlayerId		= playerId;
			_reEntrySeatId			= seatId;
			var gameSeat:SeatImpl 	= GameUtil.getSeatBySeatId(_gameImpl, seatId);
			var player:PlayerImpl	= GameUtil.getPlayerById(_gameImpl, playerId);
			gameSeat.player 		= player;
			
			var relSeatPos:int = GameUtil.getRelativeSeatPosition(gameSeat.seatId, _mySeatId, _gameImpl.seat.length);
			_seats[relSeatPos].seatPlayer(gameSeat, (_gameImpl is PointsGameImpl), -1, player);
			
			if (gameSeat.player && gameSeat.player.name)
			{
				var message:String = gameSeat.player.name  + " has joined the table.";
				ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
				ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
			}
			updateWallet(playerId, amount);
		}
		
		private function onPlayerJoined(seatImpl:SeatImpl, player:PlayerImpl, amount:int):void
		{
			if (!seatImpl)
				return;
			var relSeatPos:int = GameUtil.getRelativeSeatPosition(seatImpl.seatId, _mySeatId, _seats.length);
			_seats[relSeatPos].seatPlayer(seatImpl, (_gameImpl is PointsGameImpl), -1, player);
			
			// notify
			if (seatImpl && seatImpl.player.name)
			{
				var message:String = seatImpl.player.name  + " has joined the table.";
				ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
				ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
				showDealerMessage(message, 2);
			}
			
			updateWallet(player.id, amount);
			
			SoundDirector.getInstance().playSound(SoundDirector.DINGDONG, 0.2); // DINGDONG
		}
		
		// on Player Middle join 
		// values from server - game, seatId, match, seatImpl, deal, handCards, minBuyIn, turnTimeRemaining, turnTimerSeatId, displayId;
		protected function onMiddleJoin(data:Object):void
		{
			currentGameId	= data.displayId;
			SFSInterface.getInstance().isMiddleJoin	= true;
			removeMessage();
			_isMiddleJoin	= true;
			showDealerMessage("You have joined in the middle, please wait for others to finish the game.", 2);
			
			_matchImpl = data.match;
			_dealImpl = data.deal;
			_handCardsImpl = data.handCards;
			onSeatAllotted(data.game, data.seatId, data.minBuyIn, data.player, data.seatImpl);
			SFSInterface.getInstance().getGameRoom(_gameView.room.id).chatLogs.isSpectator = true;			
			if (_matchImpl != null)
			{
				var matchPlayer:MatchPlayerImpl;
				var len:int	= _matchImpl.matchplayer.length;
				for(var i:int=0; i<len; i++)
				{
					matchPlayer	= _matchImpl.matchplayer[i];
					if(matchPlayer.dbId	== data.player.id)
					{
						_isReEntry				= true;
						_reEntryPlayerId		= data.player.id;
						_reEntrySeatId			= data.seatId;
						break;
					}
				}
				_gameView.setRound(data.displayId);
				onCardsDealComplete();
				
				if (data.turnTimeRemaining > 0)
					onTurnOver(data.turnTimerSeatId, data.turnTimeRemaining);
			}
			
			if(_dealerSymbol)
			{
				_dealerSymbol.removeFromParent();
				_dealerSymbol	= null;
				_isDealerSet = true;
			}
			_isGamePaused = false;
			
			if(data.deal==null)
				hideAllHandCards();
		}
		
		// my table seat notification
		protected  function myTableJoin(data:Object):void
		{
			currentGameId			= data.displayId;
			_isPlayerDropped		= false;
			_isJoinedFromMyTable	= true;
			_openCard				= data.discardedCard;
			openDeckImpl			= data.openDeck;
			removeMessage();
			_isMiddleJoin	= false;
			_settlement		= data.matchSettlement;
			showDealerMessage("You have joined the same room", 2);
			
			_matchImpl = data.match;
			_dealImpl	= null;
			_dealImpl = data.deal;
			if(data.openDeck != null)
				_dealImpl.opendeck	= data.openDeck;
				
			_handCardsImpl = data.handCards;
			onSeatAllotted(data.game, data.seatId, data.minBuyIn, data.player, data.seatImpl);
			mySeat.updateProfilePic();
			//SFSInterface.getInstance().getGameRoom(_gameView.room.id).chatLogs.isSpectator = true;			
			if (_matchImpl != null)
			{
				_gameView.setRound(data.displayId,data.roundCount);
				onCardsDealComplete();
				
				var dealPlayer:DealPlayerImpl;
				var len:int	= _dealImpl?_dealImpl.dealplayer.length:0;
				 _needToRunTurnTimer	= true;
				
				for(var i:int=0; i<len; i++)
				{
					dealPlayer	= _dealImpl.dealplayer[i];
					if(dealPlayer.dbId == data.player.id && dealPlayer.state == 9)
						_needToRunTurnTimer	= false;
				}
				
				if(data.turnTimerSeatId != data.currentOpenCardTurn && data.openDeck && data.openDeck.card.length <=1)
				{
					_isFirstTurn	= true;
				}
				else if((data.turnTimerSeatId == data.currentOpenCardTurn) && data.openDeck && data.openDeck.card.length <=1)
				{
					_isFirstTurn	= true;
				}
				if (data.turnTimeRemaining > 0 && !(data.isShowInitiator))
					onTurnOver(data.turnTimerSeatId, data.turnTimeRemaining, true, data.currentOpenCardTurn);
			}
			
			_isGamePaused = false;
			
			if (!(_gameImpl is PointsGameImpl))
				updatePlayerScore(_matchImpl);
			
			updateDealPlayerCard();
			
			if(data.showTicker > 0)
			{
				var dealPlayers:Array	= _dealImpl.dealplayer;
				var playersLen:int 		= dealPlayers.length;
				
				if(!data.isShowSubmitted && !_isPlayerDropped)
				{
					var message:String = "Prepare your cards to submit. " 
					
					showCountDownMessage(message, data.showTicker, null, null, false);
					_inGameHud.setForSubmit();
				}
				else if(!_isPlayerDropped)
				{
					onShowCards(_mySeatId, data.showTicker, 0,null);
				}
			}
			if(data.isShowInitiator && !data.isShowSubmitted)
			{
				isShowInitiated	= true;
				message = "You have initiated a show. Please declare your cards  ";
				if(data.showInitTicker >0)
				{
					showCountDownMessage(message, data.showInitTicker, onDeclareTimeOut);
				}
				_inGameHud.showDeclareBtn();
			}
			if(data.isShowSubmitted)
				_gameView.tableView.meldArea.isSubmitted	= true;
			
			//
			if(data.deal==null)
			{
				hideAllHandCards();
				_isFirstTurn	= true;
			}
			if(_gameImpl is PointsGameImpl)
				showGamestartTimer();
			
			if (gameImpl && _dealImpl && (gameImpl is SyndicateGameImpl || gameImpl is BestOfNGameImpl))
				_gameView.setPrizeMoney(_dealImpl.gameprize);
			else
				_gameView.hidePrizeMoney();
		}
		
		private function showGamestartTimer():void
		{
			//var Width:int	= Constants.TARGET_WIDTH;
			//var Height:int	= Constants.TARGET_HEIGHT;
			
			_pointRummyTImer = new Timer(1000, 7200);
			_pointRummyTImer.addEventListener(TimerEvent.TIMER, onPointRummyTimerTick);
			
			_pointRummyTImer.start();
			if (_lblPointRummyTimer == null)
			{
				_pointRummyTimerBackground 		= new Image(MangoAssetManager.I.getTexture("timer_bg"));
				_pointRummyTimerBackground.x 	= WIDTH-100;
				_pointRummyTimerBackground.y 	= 90;
				//addChildAt(_pointRummyTimerBackground,10);
				
				var gameTimeStr:TextField		= new TextField(1,1, "GAME TIME");
				gameTimeStr.autoSize			= TextFieldAutoSize.BOTH_DIRECTIONS;
				gameTimeStr.x					= WIDTH- 100;
				gameTimeStr.y					= 68;
				gameTimeStr.format.color		= Color.GREEN;
				//addChildAt(gameTimeStr, 11);
				
				_lblPointRummyTimer 			= new TextField(1, 1, "00:00");
				_lblPointRummyTimer.autoSize 	= TextFieldAutoSize.BOTH_DIRECTIONS;
				_lblPointRummyTimer.format.font 	= "Arial";
				_lblPointRummyTimer.format.size 	= Fonts.getInstance().mediumFont;
				_lblPointRummyTimer.format.color 		= Color.WHITE;
				_lblPointRummyTimer.x 			= WIDTH-90;
				_lblPointRummyTimer.y 			= 105;
				_lblPointRummyTimer.alignPivot("left", "center");
				//addChildAt(_lblPointRummyTimer, 12);
			}
			else
			{
				_pointRummyTimerBackground.visible = true;
				_lblPointRummyTimer.visible = true;
			}
		}
		
		public function putSoundIcon():void
		{
			var buttonOn:Button = new Button(MangoAssetManager.I.getTexture("sound_btn"));
			var buttonOff:Button = new Button(MangoAssetManager.I.getTexture("no_sound_btn"));
			var buttonOff_Bg:Button = new Button(MangoAssetManager.I.getTexture("no_sound_btn_bg"));
			buttonOn.addEventListener(starling.events.Event.TRIGGERED, toggleSound);
			buttonOff.addEventListener(starling.events.Event.TRIGGERED, toggleSound);
			buttonOff.addChild(buttonOff_Bg);
			buttonOff_Bg.x = buttonOff_Bg.y = -5;
			buttonOn.x = buttonOff.x = 10;
			buttonOn.y = buttonOff.y = 10;
			
			if (SoundDirector.getInstance().isMuted)
			{
				Starling.current.stage.removeChild(buttonOn);
				Starling.current.stage.addChild(buttonOff);
			}
			else
			{
				Starling.current.stage.removeChild(buttonOff);
				Starling.current.stage.addChild(buttonOn);
			}
			
			function toggleSound():void
			{
				if (SoundDirector.getInstance().isMuted)
				{
					SoundDirector.getInstance().muteAll(false);
					Starling.current.stage.removeChild(buttonOff);
					Starling.current.stage.addChild(buttonOn);
				}
				else
				{
					SoundDirector.getInstance().muteAll(true);
					Starling.current.stage.removeChild(buttonOn);
					buttonOff.addChild(buttonOff_Bg);
					buttonOff_Bg.x = buttonOff_Bg.y = -5;
					Starling.current.stage.addChild(buttonOff);
				}
			}
		}
		
		private function onSpectatorJoin(data:Object):void
		{
			if(settingsBtn)
				settingsBtn.enabled	= false;
			
			SFSInterface.getInstance().getGameRoom(_gameView.room.id).chatLogs.isSpectator = true;	
			currentGameId			= data.displayId;
			isSpectator				= true;
			_isPlayerDropped		= false;
		//	_isJoinedFromMyTable	= true;
			_openCard				= data.discardedCard;
			openDeckImpl			= data.openDeck;
			removeMessage();
			_isMiddleJoin	= false;
			_settlement		= data.matchSettlement;
			showDealerMessage("You have joined the same room", 2);
			
			_matchImpl = data.match;
			_dealImpl	= null;
			_dealImpl = data.deal;
			if(data.openDeck != null)
				_dealImpl.opendeck	= data.openDeck;
			
			//_handCardsImpl = data.handCards;
			onSeatAllotted(data.game, data.seatId, data.minBuyIn, data.player, data.seatImpl);
			//SFSInterface.getInstance().getGameRoom(_gameView.room.id).chatLogs.isSpectator = true;			
			if (_matchImpl != null)
			{
				_gameView.setRound(data.displayId, data.roundCount);
				if (gameImpl && (gameImpl is SyndicateGameImpl || gameImpl is BestOfNGameImpl))
				{
					if(_dealImpl) _gameView.setPrizeMoney(_dealImpl.gameprize);
				}
				
				onCardsDealComplete(null, true);
				
				var dealPlayer:DealPlayerImpl;
				var len:int	= _dealImpl?_dealImpl.dealplayer.length:0;
				_needToRunTurnTimer	= true;
				
				for(var i:int=0; i<len; i++)
				{
					dealPlayer	= _dealImpl.dealplayer[i];
					/*if(dealPlayer.dbId == data.player.id && dealPlayer.state == 9)
						_needToRunTurnTimer	= false;*/
				}
				
				if(data.turnTimerSeatId != data.currentOpenCardTurn && data.openDeck && data.openDeck.card.length <=1)
				{
					_isFirstTurn	= true;
				}
				else if((data.turnTimerSeatId == data.currentOpenCardTurn) && data.openDeck && data.openDeck.card.length <=1)
				{
					_isFirstTurn	= true;
				}
				if (data.turnTimeRemaining > 0 && !(data.isShowInitiator))
					onTurnOver(data.turnTimerSeatId, data.turnTimeRemaining, true, data.currentOpenCardTurn);
			}
			
			_isGamePaused = false;
			
			if (!(_gameImpl is PointsGameImpl))
				updatePlayerScore(_matchImpl);
			
			updateDealPlayerCard();
			
			if(data.showTicker > 0)
			{
				var dealPlayers:Array	= _dealImpl.dealplayer;
				var playersLen:int 		= dealPlayers.length;
				
			/*	if(isSpectator)
				{
					onShowCards(_mySeatId, data.showTicker, 0, null);
				}
				else*/ 
				if(!data.isShowSubmitted && !_isPlayerDropped && !isSpectator)
				{
					var message:String = "Prepare your cards to submit. " 
					showCountDownMessage(message, data.showTicker,null, null, false);
					_inGameHud.setForSubmit();
				}
				else if(!_isPlayerDropped && !isSpectator)
				{
					onShowCards(_mySeatId, data.showTicker, 0, null);
				}
			}
	
			if(data.deal==null)
			{
				hideAllHandCards();
				_isFirstTurn	= true;
			}
			if(_gameImpl is PointsGameImpl)
				showGamestartTimer();
		}
		
		private function updateDealPlayerCard():void
		{
			var dealPlayer:DealPlayerImpl;
			
			if(!_dealImpl || !_dealImpl.dealplayer || _dealImpl.dealplayer.length < 1)
				return;
			
			var len:int	= _dealImpl.dealplayer.length;
			
			for(var i:int=0; i<len; i++)
			{
				dealPlayer	= _dealImpl.dealplayer[i];
				
				if (dealPlayer.state >4 && dealPlayer.state <9)
				{
					var seat:SeatView = getSeatByPlayerId(dealPlayer.dbId);
					if (seat)
					{
						if (dealPlayer.dbId == SFSInterface.getInstance().userInfo.id)
						{
							_isPlayerDropped	= true;
							_gameView.tableView.meldArea.fold();
							isMyTablePlayerDropped	= true;
						}
							
						else
							seat.addDropAnimtion();
					}
				}
			}
		}
		
		private function updatePlayerScore(match:MatchImpl):void
		{
			
			if (!_gameImpl || !match || !match.matchplayer || match.matchplayer.length < 1)
				return;
			
			var dealPlayerPenaltyScore:int;
			
			for (var i:int = 0; i < match.matchplayer.length; i++)
			{
				var matchPlayer:MatchPlayerImpl = match.matchplayer[i];
				
				var cumulativeScore:int = 0;
				
				var seat:SeatView = getSeatByPlayerId(matchPlayer.dbId);
				
				if (seat)
				{
					for (var j:int = 0; j < matchPlayer.score.length; j++)
					{
						var score:ScoreImpl = matchPlayer.score[j];
						cumulativeScore += score.score;
					}
					// check if deal player has any penalty
					dealPlayerPenaltyScore	= getDealPlayerScore(matchPlayer.dbId);
					if(dealPlayerPenaltyScore <0)
						dealPlayerPenaltyScore = 0;
					cumulativeScore	+= dealPlayerPenaltyScore;
					
					seat.updateScore(cumulativeScore, true);
				}
			}
		}
		
		private function getDealPlayerScore(playerId:int):int
		{
			var score:int	= 0;
			var dealPlayer:DealPlayerImpl;
			
			if(!_dealImpl || !_dealImpl.dealplayer || _dealImpl.dealplayer.length < 1)
			{
				return score;
			}
			else
			{
				var len:int	= _dealImpl.dealplayer.length;
				for(var i:int=0; i<len; i++)
				{
					dealPlayer	= _dealImpl.dealplayer[i];
					if(dealPlayer.dbId == playerId)
						return score	= dealPlayer.score.score;
				}
			}
			return score;
		}
		
		public function onDisableLeaveBtn():void
		{
			_inGameHud.onDisableLeaveBtn();
		}
		
		public function onEnableLeaveBtn():void
		{
			_inGameHud.onEnableLeaveBtn();
		}

		
		protected function onRejoin(playerId:int, highestPoints:int, forceExit:int):void
		{
			if (playerId == SFSInterface.getInstance().userInfo.id)
			{
				PopUpManager.root = _gameView;
				PopUpManager.addPopUp(new RejoinPopup(highestPoints, forceExit, _gameView.room, onRejoinCancel, playerId));
			}
			else
			{
				var seat:SeatImpl = getSeatByPlayerId(playerId).seatImpl;
				if (seat && seat.player)
					showDealerMessage(seat.player.name + " has rejoined the game!", 2);
			}
		}
		
		private function onRejoinCancel(playerId:int):void
		{
			if(gameImpl is SyndicateGameImpl)
			{
				var player:PlayerImpl = GameUtil.getPlayerById(_gameImpl, playerId);
				SFSInterface.getInstance().setPlayerNameById(playerId, player?player.name:"");
			}
		}
		
		protected function onRejoinResp(playerId:int, highestPoints:int, seatId:int):void
		{
			var seat:SeatView = getSeatByPlayerId(playerId);
			// FIX ME : why it is null
			// trying with the seatId
			if(seat == null)
				seat	= getSeatBySeatId(seatId);
			if (seat)
				seat.updateScore(highestPoints, true);
		}
		
		protected function onPlayerLeft(seatId:int, playerId:int, onLeaveTable:Boolean=false):void
		{
			var seatView:SeatView;
			if(playerId ==0)
			{
				seatView= getSeatBySeatId(seatId);
				if(_mySeatId == seatId)
					return;
			}
			else
			{
				seatView= getSeatByPlayerId(playerId);
				var tempSeatId:int	= seatView && seatView.seatImpl ? seatView.seatImpl.seatId : -1;
				if (tempSeatId == -1 || _mySeatId == tempSeatId)
					return;
			}
			
			if (seatView)
			{
				if (seatView.seatImpl && seatView.seatImpl.player)
				{
					showDealerMessage(seatView.seatImpl.player.name + " has left the table.", 2);
					_discardedCardView.removeTabForPlayer(seatView.seatImpl.player.name);
				}
				seatView.makeEmpty();
				
				if(onLeaveTable)
					return;
				_inGameHud.onEnableLeaveBtn();
				
				if (_gameImpl)
				{
					for(var i:int = 0; i < _gameImpl.seat.length; i++)
					{
						if((_gameImpl.seat[i].seatId == seatId))
						{
							if(gameImpl is SyndicateGameImpl && _gameImpl.seat[i].player)
								SFSInterface.getInstance().setPlayerNameById(_gameImpl.seat[i].player.id, _gameImpl.seat[i].player.name);
							
							_gameImpl.seat[i].player = null;
							break;
						}
					}
				}
			}
			
			
		}
		
		private function onPlayerGone(seatId:int):void
		{
			var seatView:SeatView = getSeatBySeatId(seatId);
			if (seatView)
				seatView.isGone	= true;
		}
		
		protected function onPlayerDropped(seatId:int, playerId:int, penaltyScore:int):void
		{
			var len:int	= _matchImpl.matchplayer.length;
			var matchPlayer:MatchPlayerImpl;
			var dealNo:int;
			var currentDealNo:int;
			var scoreImpl:ScoreImpl;
			// updating the score as soon as, player get dropped from the current match
			for(var i:int=0; i<len; i++)
			{
				matchPlayer	= _matchImpl.matchplayer[i];
				if(matchPlayer.dbId == playerId)
				{
					currentDealNo	= matchPlayer.score.length> 0? matchPlayer.score.length+1:0;
					dealNo	= currentDealNo>0? currentDealNo-1:0;
					scoreImpl	= new ScoreImpl();
					scoreImpl.dealnum	= dealNo;
					scoreImpl.score		= penaltyScore;
					matchPlayer.score.push(scoreImpl);
					break;
				}
			}
			
			var seatView:SeatView = getSeatBySeatId(seatId);
			
			if (seatId != _mySeatId && seatView)
			{
				seatView.addDropAnimtion();
			}
			else
			{
				_isDropped	= true;
				
			}
			if(gameImpl is SyndicateGameImpl)
			{
				if(seatView) seatView.updateScore(penaltyScore);
			}
			if(seatView && seatView.seatImpl)
			{
				var message:String = (seatView.seatImpl.player ? seatView.seatImpl.player.name : "null")  + " is dropped.";
				ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
				ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
			}
		}
		
		private function onBuyIn():void
		{
			var balance:int;
			
			if(_gameView.room.getVariable("RealOrFun").getIntValue() == 0)
				balance = SFSInterface.getInstance().userInfo.chips;
			else
				balance = SFSInterface.getInstance().userInfo.gold;
				
			var buyInPupUp:BuyInPopUp = new BuyInPopUp(_minBuyIn, balance, onBuyInOk);
			PopUpManager.root = _gameView;
			PopUpManager.addPopUp(buyInPupUp);
			
			function onBuyInOk(amount:int):void
			{
				var me:SeatView 		= getSeatBySeatId(0);
				var playerId:int		= SFSInterface.getInstance().userInfo.id; 
				var player:PlayerImpl 	= GameUtil.getPlayerById(_gameImpl, playerId);
				
				if (amount == -2)
				{
					SFSInterface.getInstance().sendRoomInfo(_gameView.room, true);
					SFSInterface.getInstance().closeRoom(_gameView.room.id, true);
				}
				else if (amount+player.wallet < _minBuyIn)//|| balance < _minBuyIn
				{
					if(balance < _minBuyIn)
						gameView.admmsgSignal.dispatch(0, "no.chips", "");
					else
						gameView.admmsgSignal.dispatch(0, "", "You didn't buy enough chips");
				}
				else
				{
					/*if (me && me.seatImpl)
					{*/
						trace ("Buy..in");
						SFSInterface.getInstance().sendBuyIn(amount+player.wallet, _gameView.room);
					//}
				}
			}
		}
		
		public function onRebuyBuyIn():void
		{
			var balance:int;
			
			if(_gameView.room.getVariable("RealOrFun").getIntValue() == 0)
				balance = SFSInterface.getInstance().userInfo.chips;
			else
				balance = SFSInterface.getInstance().userInfo.gold;
			
			var buyInPupUp:BuyInPopUp = new BuyInPopUp(_minBuyIn, balance, onBuyInOk, false);
			PopUpManager.root = _gameView;
			PopUpManager.addPopUp(buyInPupUp);
			
			function onBuyInOk(amount:int):void
			{
				if (amount == -2)
				{
					//SFSInterface.getInstance().closeRoom(_gameView.room.id, true);
				}
				else
				{
					//var me:SeatView = getSeatBySeatId(0);
					if (balance < amount || amount < _minBuyIn)
					{
						PopUpManager.addPopUp(new ConfirmationPopup("FAILED", "Buy in failed! Do you want to buy some chips", onOk, onCancel, 2, null));
					}
					
					else
					{
						SFSInterface.getInstance().sendBuyIn(amount, _gameView.room);
					}
					
					function onOk():void
					{
						navigateToURL(new URLRequest("https://ace2jak.com/useraccounts/buy"), "_blank");
						//SFSInterface.getInstance().closeRoom(_gameView.room.id, true);
					}
					
					function onCancel():void
					{
						
					}
				}
			}	
		}
		
		private function onBuyInSuccess(player:PlayerImpl):void
		{
			updateWallet(player.id, player.wallet);
		}
		
		private function onBuyInError():void
		{
			PopUpManager.root = _gameView;
			PopUpManager.addPopUp(new ConfirmationPopup("FAIL", "Buy in failed!", onOk, null, 2, onOk));
			
			function onOk():void
			{
				SFSInterface.getInstance().closeRoom(_gameView.room.id, true);
			}
		}
		
		private function onOppBuyIn(playerId:int, amount:int):void
		{
			updateWallet(playerId, amount);
		}
		
		private function onUpdateWallet(playerId:int, amount:int):void
		{
			updateWallet(playerId, amount);
			showRebuyAfterUpdateWallet(playerId, amount);
		}
		
		private function showRebuyAfterUpdateWallet(playerId:int, amount:int):void
		{
			if (playerId == SFSInterface.getInstance().userInfo.id)
			{
				if(amount < _minBuyIn *3 && _gameImpl is PointsGameImpl)
				{
					_inGameHud.btnRebuy.visible = true;
				}
				else
				{
					_inGameHud.btnRebuy.visible = false;
				}
			}
		}
		
		private function updateWallet(playerId:int, amount:int):void
		{
			var seatView:SeatView
			
/*			if ((_gameImpl is BestOfNGameImpl))
			{
				seatView = getSeatByPlayerId(playerId);
				if(seatView)
					seatView.updateScore(amount);
			}*/
			if (!(_gameImpl is PointsGameImpl))
				return;
			
			seatView = getSeatByPlayerId(playerId);
			if (!seatView)
				return;
			
			seatView.updateWallet(amount);
			
		}
		
		private function onStartCountDown(tick:int):void
		{
			if (tick <= 0)
				return;
			
			onStopCountDown(); // first reomve any existing timer
			showCountDownMessage("Game starts in ", tick, removeMsgBg,onLast1SecCountDown);
			
		}
		
		private function removeMsgBg():void
		{
			if(_msgBg)
			{
				_msgBg.removeFromParent();
				_msgBg	= null;
			}
			if(this.contains(_countDownView))
				removeChild(_countDownView);
		}
		
		private function showCountDownMessage(message:String, timer:int, callBack:Function=null, notifyCallBack:Function=null, viewNeeded:Boolean=true):void
		{
			_countDownView 		= new CountDownView(timer, message, true, true, viewNeeded?_gameView:null, callBack, notifyCallBack);
			//_countDownView.alignPivot();
			addChild(_countDownView);
			_countDownView.x 	= (WIDTH - _countDownView.width) / 2;
			_countDownView.y 	= ((HEIGHT - _countDownView.height) / 2)+18;
		}
		
		// not allowing user to join in last 1 min
		private function onLast1SecCountDown():void
		{
			if(_gameImpl is SyndicateGameImpl)
			{
				SFSInterface.getInstance().sendRoomCloseNotify(_gameView.room);
			}
		}
		
		private function onStopCountDown():void
		{
			if (_countDownView)
				_countDownView.dispose();
			_countDownView = null;
		}
		
		private function onReshuffle():void
		{
			PopUpManager.root = _gameView;
			PopUpManager.addPopUp(new ReshufflePopup());
			
			_discardedCardView.resetCardContainers();
		}
		
		private function onMatchStarting(matchImpl:MatchImpl):void
		{
			// maximize chat
			ProxySignals.getInstance().toggleChatWindowSignal.dispatch(false, _gameView.room.id);
			
			_settlementPopup		= null;
			isRandomizerDone		= false;
			_isReEntry				= false;
			_reEntrySeatId			= -1;
			_isJoinedFromMyTable	= false;	
			_needToRunTurnTimer		= true;
			isMyTablePlayerDropped	= false;
			_canDeclare				= false;// change 
			SFSInterface.getInstance().isMiddleJoin	= false;
			_inGameHud.setForDeclare();
			_inGameHud._isPlayerDropped	= false;
			_matchImpl = matchImpl;		
			_isFirstTurn = true; // doing here for Point rummy
			_isDropped		= false;
			if (_gameImpl is PointsGameImpl)
			{
				_inGameHud.removeAutoDropPopup();
				_isAutoDrop = false;
			}
			
			else 
			{
				
				var gameType:String = GameStatsView.getRoomNameStringByGroupId(gameView.room);
				if (gameType == "201 Pool" || gameType == "101 Pool")
				{
					_inGameHud.removeAutoDropPopup();
					_isAutoDrop = false;
				}
			}
			showDealerMessage("New Match starts in few seconds", 2);
		}
		
		
		private function onPointRummyTimerTick(event:TimerEvent):void
		{
			var seconds:int = _pointRummyTImer.currentCount;
			
			var minute:int = seconds / 60;
			var decimalMinute:int = minute / 10;
			var minutesOnceValue:int = minute % 10;
			
			var remainingSecond:int = seconds % 60;
			
			var decimalSecond:int = remainingSecond/ 10;
			var secondsOnceValue:int = remainingSecond % 10;
			
			var time:String = decimalMinute.toString() + minutesOnceValue.toString() + ":" + decimalSecond.toString() + secondsOnceValue.toString(); 
			
			_lblPointRummyTimer.text = time;
		}
		private function onMatchStarted(currentTurnSeatId:Number, timeOut:int):void
		{
			// maximize chat
			//ProxySignals.getInstance().toggleChatWindowSignal.dispatch(false, _gameView.room.id);
			
			//_isMiddleJoin	= false;
			 mySeat.updateProfilePic();
			
			_isAutoDrop = false;
			_inGameHud._isPlayerDropped	= false;
			isMyTablePlayerDropped	= false;
			//_isDealerSet	= false;
			_matchLeavePlayersCount	= 0;
			var message:String = "Match has started.";
			ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
			ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
			
			SFSInterface.getInstance().getGameRoom(_gameView.room.id).chatLogs.isSpectator = false;
			_gameView.leaveTableEnableSignal.dispatch();
			onTurnOver(currentTurnSeatId, timeOut);
			_isGamePaused = false;
			_isMatchOver = false;
		}
		
		protected function onShuffleAndDeal(deal:DealImpl, handCards:HandCardsImpl, roundCount:int, displayId:String):void
		{
			//SFSInterface.getInstance().removeReEntryPlayer(_gameView.room, _mySeatId, SFSInterface.getInstance().userInfo.id);
			lastGameId		= currentGameId;
			currentGameId	= displayId;	
			
			removeMessage();
			onEnableLeaveBtn();
			
			//if(!_isMiddleJoin)
				_dealImpl = deal;
			_handCardsImpl = handCards;
			
			var isPointGame:Boolean = _gameImpl is PointsGameImpl;
			_gameView.setRound(displayId, roundCount);
			
			// prize money
			if (gameImpl && (gameImpl is SyndicateGameImpl || gameImpl is BestOfNGameImpl))
				_gameView.setPrizeMoney(_dealImpl.gameprize);
			else
				_gameView.hidePrizeMoney();
			
			if(_gameImpl is PointsGameImpl)
				showGamestartTimer();
			
			_cardShuffleMachine.dealPositions = getPlayingSeatPositions();
			_cardShuffleMachine.startDeal(CARDS_TO_DEAL);
			
			SoundDirector.getInstance().playSound(SoundDirector.CARD_SHUFFLESLOW);
			
			_cardShuffleMachine.addEventListener(MenuEvent.CARDS_DEAL_COMPLETE, onCardsDealComplete);			
			
			//showDealerMessage("Card distributed, round starts soon.", 2);
			
			_isGamePaused = true;
			
			// minimize chat
			//ProxySignals.getInstance().toggleChatWindowSignal.dispatch(true, _gameView.room.id);
			
			// set the show button
			_inGameHud.setForDeclare();
			_isDealerSet	= false;
			
			//SFSInterface.getInstance().killConnection();
		}
		
		public function checkingForValidShow():Boolean
		{
			if(_lastTurnSeat)
			{
				if(_lastTurnSeat.seatImpl.seatId == _mySeatId)
				{
					return true;
				}
			}
			return false
		}
		
		protected function onTurnOver(seatId:int, timeOut:int, isMyTablePlayer:Boolean=false, openCardSeatId:int=0):void
		{
			//SoundDirector.getInstance().playSound(SoundDirector.TING);
			
			if (_lastTurnSeat)
			{
				if(_lastTurnSeat.seatImpl.seatId == _mySeatId)	_lastTurnSeat.updateProfilePic();
				_lastTurnSeat.removeTurnTimer();
			}
			
			if (_isFirstTurn)
			{
				_isFirstTurn = false;
				if (seatId != _mySeatId)
				_inGameHud.autoDropButtonVisible(true);
			}
			
			_lastTurnSeat = getSeatBySeatId(seatId);
			if (_lastTurnSeat) // FIXME: why is it null??
			{
				_lastTurnSeat.addTurnTimer(timeOut);
				if (seatId == _mySeatId)
				{
					_lastTurnSeat.updateProfilePic();
					if (_isAutoDrop)
					{
						_inGameHud.autoDropAfterTurn();
						_inGameHud.removeAutoDropPopup();
					}
					else
					{
						_inGameHud.autoDropButtonVisible(false);
						dispatchGameTabHighlightSignal();
					}
				}
				
				if(isSpectator || isMyTablePlayer || (_gameImpl is SyndicateGameImpl) || (_gameImpl is BestOfNGameImpl))
				{
					if (!_isDealerSet)
					{
						if(isMyTablePlayer)
							setDealerPos(openCardSeatId);
						else
							setDealerPos(seatId);
						
						_isDealerSet = true;
					}
				}
				else if(!isRandomizerDone && !_isDealerSet)
				{
					setDealerPos(seatId);
					_isDealerSet = true;
				}
			}
		}
		
		protected function setDealerPos(seatId:int, isFromSeatShuffle:Boolean=false):void
		{
			// cleaning up the last dealer
			removeLastDealer();
			
			// setting up the current dealer
			setDealer(seatId, isFromSeatShuffle);
		}
		
		private function onShowInitiated(seatId:int, timeout:int):void
		{
			// Rmoving turn timer once show initiated
			if (_lastTurnSeat)
				_lastTurnSeat.removeTurnTimer();
			
			var message:String = "";
			
			if (seatId == _mySeatId && !isSpectator)
			{
				isShowInitiated	= true;
				message = "You have initiated a show. Please declare your cards  ";
				
				showCountDownMessage(message, timeout-1);
				
			}
			else
			{
				var seat:SeatImpl = GameUtil.getSeatBySeatId(_gameImpl, seatId);
				if (seat && seat.player)
					message = seat.player.name  + " has initiated a show.";
				
				ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
				ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
				showDealerMessage(message, 2);
			}
		}
		
		private function onDeclareTimeOut():void
		{
			_inGameHud.disableDeclareBtn();
		}
		
		protected function onInvalidShow(playerId:int, discardedCard:CardImpl, wrongPenalty:int):void
		{
			_gameView.tableView.meldArea.removeAddHereButtonsIfAny();
			_gameView.tableView.meldArea.disableGroupBtnsIfAny();
			_gameView.tableView.meldArea._isDeclared	= false;
			var message:String = "";
			var seat:SeatView = getSeatByPlayerId(playerId);
			if (playerId == SFSInterface.getInstance().userInfo.id)
			{
				message = "You have placed a Wrong Show";
				_gameView.tableView.meldArea.fold();
			}
			else
			{
				if (seat.seatImpl && seat.seatImpl.player)
				{
					seat.addDropAnimtion();
					message = seat.seatImpl.player.name + " has placed a wrong show";
				}
			}
			if(gameImpl is SyndicateGameImpl || gameImpl is BestOfNGameImpl)
			{
				seat.updateScore(wrongPenalty);
			}
			showDealerMessage(message, 3);
		}
		
		public function removeExtraPopups():void
		{
			if(_avatarPopup)
				PopUpManager.removePopUp(_avatarPopup);
			if(_gameRulesPopup)
				PopUpManager.removePopUp(_gameRulesPopup);
		}
		
		protected function onCardsShownDone(seatId:int, playerId:int, score:int, handCards:HandCardsImpl, wonOrLoss:int, dealPlayers:SFSArray):void
		{
			removeExtraPopups();
			_inGameHud.removePopupsIfAny();
			var seatVw:SeatView	= getSeatBySeatId(seatId);
			if (!(gameImpl is PointsGameImpl))
				seatVw.updateScore(score);
			
			if(playerId == SFSInterface.getInstance().userInfo.id)
			{
				_settlementPopup	= new SettlementPopup(this);
				PopUpManager.root 	= _gameView;
				PopUpManager.addPopUp(_settlementPopup);
				
				if (gameImpl is PointsGameImpl)
					_settlementPopup.setForPoint(false, gameView.room.getVariable("Bet").getIntValue())
				else
					_settlementPopup.setForPool(false);
				
				var myPlayer:PlayerImpl	= GameUtil.getPlayerBySeatId(_gameImpl, seatId);
				_settlementPopup.showScoreValues(myPlayer, dealPlayers, handCards, score);
			}
			
			if(_settlementPopup)
			{
				if(gameImpl is PointsGameImpl)
				{
					_settlementPopup.refresh(playerId, score, handCards, wonOrLoss);
				}
				else
				{
					var totScore:int = 0;
					var dealPlayer:DealPlayerImpl;
					
					for( var i:int=0; i<dealPlayers.size(); i++)
					{
						dealPlayer	= dealPlayers.getClass(i);
						if(playerId == dealPlayer.dbId)
							totScore	= dealPlayer.totalScore;
						
					}
					_settlementPopup.refresh(playerId, score, handCards, wonOrLoss, 0, totScore);
				}
			}
		}
		
		private function refreshOtherPlayersView(dealPlayers:SFSArray, myPlyerId:int):void
		{
			var len:int	= dealPlayers?dealPlayers.size():0;
			var dealPlayer:DealPlayerImpl;
			
			for(var i:int=0; i<len; i++)
			{
				dealPlayer	= dealPlayers.getClass(i);
				if(dealPlayer.dbId != myPlyerId)
					_settlementPopup.refresh( dealPlayer.dbId, -1, null, 0, -1);
			}
		}
		
		protected function showSettlementBoardForDroppedPlayers(seatId:int, timeout:int, score:int, allDealPlayers:SFSArray, handCards:HandCardsImpl=null, totScore:int=0):void
		{
			removeExtraPopups();
			_inGameHud.removePopupsIfAny();
			var len:int	= (allDealPlayers)?allDealPlayers.size():0;
			var dealPlayer:DealPlayerImpl;
			var myPlayerId:int	= SFSInterface.getInstance().userInfo.id;
			var isDroppedPlayer:Boolean= false;
			
			for(var i:int=0; i<len; i++)
			{
				dealPlayer	= allDealPlayers.getClass(i);
				if(dealPlayer.dbId == myPlayerId)
				{
					_settlementPopup	= new SettlementPopup(this);
					PopUpManager.root = _gameView;
					PopUpManager.addPopUp(_settlementPopup);
					var myPlayer:PlayerImpl	= GameUtil.getPlayerById(_gameImpl, myPlayerId);
					
					if (gameImpl is PointsGameImpl)
						_settlementPopup.setForPoint(false, gameView.room.getVariable("Bet").getIntValue())
					else
						_settlementPopup.setForPool(false);
					
					_settlementPopup.showScoreValues(myPlayer, allDealPlayers, handCards, score);
				}
			}
		}
		
		protected function onShowCards(seatId:int, timeout:int, score:int, leftPlayers:SFSArray, handCards:HandCardsImpl=null, totScore:int=0):void
		{
			removeExtraPopups();
			_inGameHud.removePopupsIfAny();
			
			onDisableLeaveBtn();
			_inGameHud.disableDropAndAutoDropBtns();
			
			if (_isAutoDrop)
			{
				_isAutoDrop = false;
				_inGameHud.removeAutoDropPopup();
			}
			
			if(seatId == _mySeatId)
			{
				var myPlayer:PlayerImpl	= GameUtil.getPlayerBySeatId(_gameImpl, seatId);
				
					
				_settlementPopup	= new SettlementPopup(this);
				PopUpManager.addPopUp(_settlementPopup);
				
				if (gameImpl is PointsGameImpl)
					_settlementPopup.setForPoint(false, gameView.room.getVariable("Bet").getIntValue())
				else
				_settlementPopup.setForPool(false);
				
				_settlementPopup.showScoreValues(myPlayer, leftPlayers, handCards, score, myPlayer.id, totScore);
				//_settlementPopup.refresh(myPlayer.id, score, handCards, -1); 
			}
			else
			{
				var message:String = "Prepare your cards to submit. "; 
				
				showCountDownMessage(message, timeout-1);
			}
			//_gameView.tableView.meldArea.getHandCards();
			
			
			
		}
		
		protected function onMatchSettlement(match:MatchImpl, matchSettlement:MatchSettlementImpl, timer:int, GameId:String, matchDeclared:Boolean):void
		{
			lastGameId	= GameId;
			_inGameHud.removePopupsIfAny();
			
			// sending game loginfo
			SFSInterface.getInstance().sendGameLogInfo(currentGameId, GameLogInfo.getUpdatedLog(), _gameView.room);
			
			removeMessage();
			hideAllHandCards();
			_matchImpl = match;
			_settlement = matchSettlement;
//			if (!_gameImpl is PointsGameImpl)
//			{
				_isFirstTurn = true; // For pool
				_isAutoDrop = false; // for pool I have to make it generic
				_inGameHud.removeAutoDropPopup();// For pool

			//}
			_isDropped	= false;
			_discardedCardView.visible = false;
			
			removeLastDealer();
			
			if (_gameImpl is PointsGameImpl && _pointRummyTImer)
			{
				_pointRummyTImer.stop();
				_pointRummyTImer.removeEventListener(TimerEvent.TIMER, onPointRummyTimerTick);
				_lblPointRummyTimer.visible = false;
				_pointRummyTimerBackground.visible = false;
				_lblPointRummyTimer.text = "00:00";
			}
			
			if (_lastTurnSeat)
				_lastTurnSeat.removeTurnTimer();
			_lastTurnSeat = null;
			
			if (matchSettlement.winnerId == SFSInterface.getInstance().userInfo.id)
				SoundDirector.getInstance().playSound(SoundDirector.GAME_WINNER);
			
			// show scores for all the players
			for (var i:int = 0; i < _settlement.playersSettlement.length; i++)
			{
				var playerSettlement:PlayerSettlementImpl = _settlement.playersSettlement[i];
				var seat:SeatView = getSeatByPlayerId(playerSettlement.playerId);
				//seat.updateScore(playerSettlement.totalScore);
				
				//used the loop for keeping usersettelment data in history // need to confirm from saurabh
				
				if (playerSettlement.playerId == SFSInterface.getInstance().userInfo.id && _gameImpl is PointsGameImpl)
				{
					_history.push(playerSettlement);
					_historyGameId.push(GameId);
					_inGameHud.refreshHistoryPopup();	
					
				}	
				
				/*if(_settlementPopup && playerSettlement.playerId == _settlement.winnerId)
					_settlementPopup.refresh( playerSettlement.playerId, -1, null, 0, playerSettlement.wonorloss);*/
			}
			
			var message:String = "Round over.";
			ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
			ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
			
			// minimize chat
			ProxySignals.getInstance().toggleChatWindowSignal.dispatch(true, _gameView.room.id);
			onEnableLeaveBtn();
			
			GameLogInfo.clear();
		}
		
		protected function hideAllHandCards():void
		{
			for (var i:int = 0; i < _seats.length; i++)
			{
				var seat:SeatView = _seats[i];
				var seatImpl:SeatImpl = seat.seatImpl;
		
					seat.toggleShowHandCards(false);
			}
		}
		
		protected function onAutoSplit(windrop:int):void
		{
			var message:String = "The amount has been auto-split and you have received: " + Number(windrop / 100).toFixed(2);
			PopUpManager.root = _gameView;
			PopUpManager.addPopUp(new ConfirmationPopup("AUTO-SPLIT", message, onOk, null, 10, onOk));
			
			function onOk():void
			{
				SFSInterface.getInstance().closeRoom(_gameView.room.id, false);
			}
		}
		
		private function onMatchOver():void
		{
			_matchImpl = null;
			
			var message:String = "Match over.";
			ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
			ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
			showDealerMessage(message, 2);
		}
		
		public function showMessage(msg:String): void
		{
			var message:String = msg;
			if(_beforeSeatAllotPopup !=null)
			{
				_beforeSeatAllotPopup = new ConfirmationPopup("PLEASE WAIT...", message, null, null);
				PopUpManager.addPopUp(_beforeSeatAllotPopup);
			}
			function onOk():void
			{
				//	SFSInterface.getInstance().closeRoom(_gameView.room.id, false);
			}
		}
		
		public function removeMessage():void
		{
			if (_beforeSeatAllotPopup && PopUpManager.isPopUp(_beforeSeatAllotPopup))
			{
				PopUpManager.removePopUp(_beforeSeatAllotPopup, true);
				_beforeSeatAllotPopup	= null;
			}
				
		}
		
		private function onToLobbyOnGameExit(kickout:int):void
		{
			if (kickout == 1)
			{
				var message:String 	= "Sorry! you are disqualified for the next game!" // "You have been kicked out from the game!"; 
				PopUpManager.root 	= _gameView;
				PopUpManager.addPopUp(new ConfirmationPopup("ELIMINATION", message, onOk, null, 9, onOk));
			}
			else
			{
				onOk();
			}
			
			function onOk():void
			{
				SFSInterface.getInstance().closeRoom(_gameView.room.id, false);
			}
		}
		
		private function joinFailOnRoomFull():void
		{
			removeMessage();
			var message:String 	= "Game already started, please join in another room";
			PopUpManager.root 	= _gameView;
			PopUpManager.addPopUp(new ConfirmationPopup("GAME STARTED",message, onOk, null, 6, onOk));
			
			function onOk():void
			{
				SFSInterface.getInstance().closeRoom(_gameView.room.id, false);
			}
		}
		
		protected function makeSeatsRepositions(seats:Array, dealerSeatId:int, match:MatchImpl=null, isRejoined:Boolean=false):void
		{
			var oldSeatMap:Dictionary = new Dictionary();
			
			// first vacate all the seats
			for (var i:int = 0; i < _seats.length; i++)
			{
				// keep track of existing players
				if (!_seats[i].isEmpty)
				{
					player	= _seats[i].seatImpl.player;
					oldSeatMap[player.id] = i;
					
				}
				_seats[i].makeEmpty();
			}
			
			var userInfo:UserInfo	= SFSInterface.getInstance().userInfo;
			var myPlayerId:int		= userInfo.id;
			var player:PlayerImpl;
			var seatImpl:SeatImpl;
			
			// take a note of my new position
			for (i = 0; i < seats.length; i++)
			{
				seatImpl	= seats[i];
				player		= seatImpl.player;
				if (player && player.id == myPlayerId)
				{
					_mySeatId = seats[i].seatId;
					break;
				}
			}
			
			// now make them seat accordingly
			if(_gameImpl)
			{
				_gameImpl.seat = seats;
				for (i = 0; i < seats.length; i++)
				{
					seatImpl = seats[i];
					if (seatImpl && seatImpl.player) 
					{
						var relSeatPos:int = GameUtil.getRelativeSeatPosition(seatImpl.seatId, _mySeatId, seats.length);
						player	= GameUtil.getPlayerById(_gameImpl, seatImpl.player.id);
						if(!isRejoined)
							_seats[relSeatPos].seatPlayer(seatImpl, (_gameImpl is PointsGameImpl),-1, player);
						else
							_seats[relSeatPos].seatPlayer(seatImpl, (_gameImpl is PointsGameImpl), (seatImpl.player ? oldSeatMap[seatImpl.player.id] : -10), player);
						
						// updatating players wallet's after their reposition
						if(_gameImpl is SyndicateGameImpl)
						{
							var score:int;
							var matchPlayer:MatchPlayerImpl;
							
							if(seatImpl.player && _isRejoinedSeatShuffle)
							{
								for(var k:int=0; k<match.matchplayer.length; k++)
								{
									matchPlayer		= match.matchplayer[k];
									if(seatImpl.player.id == matchPlayer.dbId)
									{
										_seats[relSeatPos].updateScore(matchPlayer.totalScore())
									}
								}
							}
						}
							
					}
				}
			}
			setDealerPos(dealerSeatId, true);
			_isRejoinedSeatShuffle	= false;
		}
		// added functionality logic in child class 
		protected function onSeatShuffle(seats:Array):void
		{
			removeMessage();
			_isMiddleJoin	= false;
			isShowInitiated	= false;
		}
		
		protected function onRejoinSeatShuffle(seats:Array, isRejoined:Boolean, leftPlayers:Array, match:MatchImpl):void
		{
			_isRejoinedSeatShuffle	= true;
		}
		
		public function getSeatBySeatId(seatId:int):SeatView
		{
			for (var i:int = 0; i < _seats.length; i++)
			{
				if (_seats[i].seatImpl && _seats[i].seatImpl.seatId == seatId)
					return _seats[i];
			}
			
			return null;
		}
		
		private function getSeatVwBySeatId(seatId:int):SeatView
		{
			return _seatsDic[seatId];
		}
		
		public function getSeatByPlayerId(playerId:int):SeatView
		{
			var seatImpl:SeatImpl;
			var player:PlayerImpl;
			
			for (var i:int = 0; i < _seats.length; i++)
			{
				seatImpl		= _seats[i].seatImpl;
				if(seatImpl)
					player		= seatImpl.player;
				if(player)
				{
					if(player.id == playerId)
						return _seats[i];
				}
				
			/*	if (_seats[i].seatImpl && _seats[i].seatImpl.player && _seats[i].seatImpl.player.id == playerId)
					return _seats[i];*/
			}
			
			return null;
		}
		
		protected function getPlayingSeatPositions():Array
		{
			var positions:Array 		= new Array();
			var gameScreen:XML 			= MangoAssetManager.I.gameElements;
			var seatsPos:XMLList		= gameScreen.theme.seats.seat;
			var player:PlayerImpl;	
			
			for (var i:int = 0; i < _seats.length; i++)
			{
				var seatView:SeatView = _seats[i];
				player				  = seatView.seatImpl?seatView.seatImpl.player:null;
				
				if (player && !seatView.isGone)
				{
					var pos:Array = new Array();
					pos[0] = seatsPos[i].handCards.@x;
					pos[1] = seatsPos[i].handCards.@y;
					positions.push(pos);
				}
			}
			return positions;
		}
		
		public function cleanup():void
		{
			_settlementPopup	= null;
			_isMatchOver = true;
			//_inGameHud.setForDeclare();
			if (_countDownView)
				_countDownView.dispose();
		}
		
		protected function onCardsDealComplete(e:Event = null, isSpectator:Boolean=false):void
		{
			_cardShuffleMachine.removeEventListener(MenuEvent.CARDS_DEAL_COMPLETE, onCardsDealComplete);
			SoundDirector.getInstance().stopSound(SoundDirector.CARD_SHUFFLESLOW);
			
			// Enable discarded card button here
			if (_discardedCardButton)
				_discardedCardButton.enabled = true;
			//var len:int	= _dealImpl.dealplayer.length;
			
			// show hand cards indicators for other players
			for (var i:int = 0; i < _seats.length; i++)
			{
				var seat:SeatView = _seats[i];
				var seatImpl:SeatImpl = seat.seatImpl;
				if ((seatImpl && seatImpl.player && seatImpl.seatId != _mySeatId))
				{
					//seat.toggleShowHandCards(true);
				}
				else if(isSpectator && seat.seatImpl && seat.seatImpl.player)
				{
					isSpectator	= false;
					seat.initHandCardsWhenSpectatorIsThere(this)
					seat.toggleShowHandCards(true);
				}
				else	
				{
					seat.toggleShowHandCards(false);
				}
				
				
				if (seatImpl && seatImpl.player)
					_discardedCardView.addTabFor(seatImpl.player.name);
			}
			
		}
		
		protected function showDealerMessage(message:String, durationInSec:int, forceTimeout:Boolean = true):void
		{
			_dealerCallout.animateCallout(message, durationInSec, forceTimeout);
		}
		
		private function pointMeOut():void
		{
			// Disable the leave table , until match starts
			onDisableLeaveBtn();
			
			// point "me" out, put an arrow to notify my seat
			// I am always seating in the center, i.e., the 0th seat position
			var seatView:SeatView = _seats[0];
			// text
			var message:String = "You"; // TextHandler.getInstance().getText("YouseatedHere");
			var textFormat:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, Fonts.getInstance().mediumFont, Color.YELLOW);
			var txtPointer:TextField = new TextField(1, 1, message, textFormat);
			txtPointer.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			addChild(txtPointer);
			txtPointer.x = seatView.x + seatView.width / 2;
			txtPointer.y = seatView.y - 150;
			
			// arrow
			var imgArrow:Image = new Image(MangoAssetManager.I.getTexture("arrow"));
			addChild(imgArrow);
			imgArrow.x = seatView.x + seatView.width/ 2;
			imgArrow.y = seatView.y - 110;
			imgArrow.scaleX	= 0.8;
			imgArrow.scaleY	= 0.8;
			
			// tween / animate
			var tween:Tween = new Tween(imgArrow, 1, Transitions.EASE_IN_OUT);
			tween.repeatCount = 2
			tween.reverse = true;
			var tableView:TableView = this;
			tween.onComplete = function():void
			{
				onEnableLeaveBtn();
				
				Starling.juggler.remove(tween);
				
				// onTween completion we are removing the arrow
				if(tableView.contains(txtPointer))
					tableView.removeChild(txtPointer, true);
				
				if(tableView.contains(imgArrow))
					tableView.removeChild(imgArrow, true);
			};
			tween.moveTo(imgArrow.x, seatView.y - 80);
			Starling.juggler.add(tween);
		}
		
		private function onAdmMsg(playerId:int , title:String , message:String):void
		{
			message = title == "no.chips" ? "You are low on cash!" : message;
			PopUpManager.root = _gameView;
			PopUpManager.addPopUp(new ConfirmationPopup("LOW CASH", message, onOk, null, 3, onOk));
			
			function onOk():void
			{
				SFSInterface.getInstance().closeRoom(_gameView.room.id, true);
			}
		}
		
		protected function onManualSplitEnabled(splitAmounts:Array, timer:int):void
		{
			_inGameHud.enableManualSplit(splitAmounts);
			
			if (timer > 0)
				_inGameHud.updateSettlementPopupTime(timer);
		}
		
		protected function onManualSplitAccepted(timeout:int, playerId:int):void
		{
			if (timeout > 0)
				_inGameHud.updateSettlementPopupTime(timeout);
			
			_inGameHud.setSplitAcceptedForPlayer(playerId, true);
		}
		
		protected function onManualSplitResult(splitDistribution:int):void
		{
			PopUpManager.root = _gameView;
			PopUpManager.addPopUp(new ConfirmationPopup("SPLIT", "Amount splitted!", onOk, null, 10, onOk));
			
			function onOk():void
			{
				SFSInterface.getInstance().closeRoom(_gameView.room.id, true);
			}
		}
		
		private function removeLastDealer():void
		{
			var seatVw:SeatView;
			
			for( var i:int=0; i<_seats.length; i++)
			{
				seatVw	= _seats[i];
				if(seatVw)
				{
					seatVw.removeLastDealerSymbol();
				}
			}
		}
		
		public function setDealer(seatId:int, isFromSeatShuffle:Boolean):void
		{
			var dealerSeatView:SeatView;
			
			// for Point rummy seatId is the Dealer seatId 
			if(isFromSeatShuffle)
			{
				dealerSeatView = getSeatBySeatId(seatId);
				
				if (dealerSeatView)
				{
					if (!dealerSeatView.isEmpty)
					{
						//dealerSeatView.seatPos;
						dealerSeatView.setDealerPos();
					}
				}
			}
			else
			{
				var currentSeatId:int = seatId;
				var dealerSeatId:int = seatId - 1;
				
				if (dealerSeatId < 0)
					dealerSeatId = 5;
				
				for (; dealerSeatId != currentSeatId ;)
				{
					dealerSeatView = getSeatBySeatId(dealerSeatId);
					
					if (dealerSeatView)
					{
						dealerSeatView.setDealerPos();
					}
					
					dealerSeatId--;
					
					if (dealerSeatId<0)
						dealerSeatId = 5;
				}
			}
			
		}
		
		public function getDealerSeatId(seatId:int, isFromSeatShuffle:Boolean):int
		{
			var dealerSeatView:SeatView;
			
			// for Point rummy seatId is the Dealer seatId 
			if(isFromSeatShuffle)
			{
				dealerSeatView = getSeatBySeatId(seatId);
				
				if (dealerSeatView)
				{
					if (!dealerSeatView.isEmpty)
						return dealerSeatView.seatPos;
				}
			}
			else
			{
				var currentSeatId:int = seatId;
				var dealerSeatId:int = seatId - 1;
				
				if (dealerSeatId < 0)
					dealerSeatId = 5;
				
				for (; dealerSeatId != currentSeatId ;)
				{
					dealerSeatView = getSeatBySeatId(dealerSeatId);
					
					if (dealerSeatView)
					{
						if (!dealerSeatView.isEmpty)
							return dealerSeatView.seatPos;
					}
					
					dealerSeatId--;
					
					if (dealerSeatId<0)
						dealerSeatId = 5;
				}
			}
			
			return -1;
		}
		
		public function dispatchGameTabHighlightSignal():void
		{
			if(isSpectator)
				return;
			
			var gameRooms:Vector.<GameRoom> = SFSInterface.getInstance().GameRooms;
			for (var i:int = 0; i < gameRooms.length; i++)
			{
				if (gameRooms[i].gameView.room.id == _gameView.room.id)
				{
					ProxySignals.getInstance().tabHighlightIngSignal.dispatch(i+1);
					break;
				}
			}
			
		}
		
		public function onLeaveTableResponse(playerId:int, seatId:int, penaltyScore:int, playersCount:int):void
		{
			
			var len:int	= _matchImpl.matchplayer.length;
			var matchPlayer:MatchPlayerImpl;
			var dealNo:int;
			var currentDealNo:int;
			var scoreImpl:ScoreImpl;
			// updating the score as soon as, player get dropped from the current match
			for(var i:int=0; i<len; i++)
			{
				matchPlayer	= _matchImpl.matchplayer[i];
				if(matchPlayer.dbId == playerId)
				{
					currentDealNo	= matchPlayer.score.length> 0? matchPlayer.score.length+1:0;
					dealNo	= currentDealNo>0? currentDealNo-1:0;
					scoreImpl	= new ScoreImpl();
					scoreImpl.dealnum	= dealNo;
					scoreImpl.score		= penaltyScore;
					matchPlayer.score.push(scoreImpl);
					break;
				}
			}
			
			var playerImpl:PlayerImpl = GameUtil.getPlayerById(_gameImpl, playerId);
			SFSInterface.getInstance().setPlayerNameById(playerId, playerImpl.name);
			
			_playersCount				= playersCount;
			var leftSeatVw:SeatView		= getSeatByPlayerId(playerId)
			_playerLeftSeatId			= leftSeatVw? leftSeatVw.seatImpl.seatId : 0;
			var seatVw:SeatView			= getSeatBySeatId(_mySeatId);
			var seatImpl:SeatImpl		= seatVw.seatImpl;
			var player:PlayerImpl		= seatImpl.player;
			var tempPlayerId:int;
			
			if(_dealerSymbol)
			{
				_dealerSymbol.removeFromParent();
				_dealerSymbol	= null;
				//_isDealerSet 	= false;
			}
			if(seatVw && (seatImpl && player))
			{
				tempPlayerId	= seatVw.seatImpl.player.id;
				if(tempPlayerId == playerId)
				{
					dispose();
					cleanup();
					SFSInterface.getInstance().closeRoom(gameView.room.id, true);
				}
				else
				{
					onPlayerLeft(seatId, playerId, true);
				}
			}
		}
		
		public function removeConfirmationPopup():void
		{
			_inGameHud.removeConfirmShowPopup();
		}
		
		protected function initDebugger():void
		{
			Cc.startOnStage(Starling.current.nativeStage, "raju"); // "`" - change for password. This will start hidden
			Cc.visible = true; // show console, because having password hides console.
			Cc.commandLine = true; // enable command line
			//Cc.memoryMonitor = true;
			//Cc.fpsMonitor = true;
			//Cc.displayRoller = true;
			
			Cc.config.commandLineAllowed = true;
			Cc.width = 700;
			Cc.height = 300;
			//Cc.config.remotingPassword = "raju"; // Just so that remote don't ask for password
			Cc.remoting = true;
			Cc.visible	= false;
			Cc.addMenu("T1", Cc.log, ["Greetings 1"], "This is a test menu 1");
			Cc.addMenu("T2", Cc.log, ["Greetings 2"], "This is a test menu 2");
			Cc.addMenu("spam100k", spam, [100000]);
			
			Cc.addSlashCommand("test", function():void{ Cc.log("Do the test!");} );
			Cc.addSlashCommand("test2", function(param:String):void{Cc.log("Do the test 2 with param string:", param);} );
			
			Cc.addSlashCommand("testmethod", function():void{ 
			onDisableLeaveBtn();
			} );
			
			Cc.addSlashCommand("testenable", function():void{ 
				onEnableLeaveBtn();
			} );
		}
		
		private function spam(chars:int):void{
			var str:String = "";
			while(str.length < chars){
				str += "12345678901234567890123456789012345678901234567890123456789012345678901234567890";
			}
			Cc.log(str.substring(0, chars));
			Cc.log("<<",chars,"chars.");
		}
		
		public function get dealImpl():DealImpl { return _dealImpl; }
		public function get settlement():MatchSettlementImpl { return _settlement; }
		public function get gameImpl():IGame { return _gameImpl; }
		public function get matchImpl():MatchImpl { return _matchImpl; }
		public function get gameView():GameView { return _gameView; }
		public function get canDrop():Boolean { return (_lastTurnSeat && _lastTurnSeat.seatImpl)? _lastTurnSeat.seatImpl.seatId == _mySeatId: false }
		public function get isGamePaused():Boolean { return _isGamePaused; }
		public function set isGamePaused(value:Boolean):void { _isGamePaused = value; }
		public function get mySeat():SeatView { return getSeatBySeatId(_mySeatId); }
		public function get isMatchOver():Boolean  { return _isMatchOver; }
		public function get history():Array{ return _history; }
		public function get historyGameId():Array{ return _historyGameId; }
		public function set isAutoDrop(value:Boolean):void{ _isAutoDrop = value;}
		public function get isDropped():Boolean { return _isDropped };
		public function get playersCount():int { return _playersCount };
		public function get isMiddleJoin():Boolean { return _isMiddleJoin }
		public function get joker():CardImpl { return _joker; }
		public function set joker(value:CardImpl):void { _joker = value; }
		public function get openCard():CardImpl	{return _openCard;}
		public function set openCard(value:CardImpl):void{_openCard = value; }

		public function get isJoinedFromMyTable():Boolean
		{
			return _isJoinedFromMyTable;
		}

		public function set isJoinedFromMyTable(value:Boolean):void
		{
			_isJoinedFromMyTable = value;
		}


;
	}
}