package com.mangogames.views.game.tableview
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.rummy.model.impl.BestOfNGameImpl;
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.GroupCardsImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.PointsGameImpl;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.AbstractBaseView;
	import com.mangogames.views.game.GameStatsView;
	import com.mangogames.views.game.HistoryPopup;
	import com.mangogames.views.game.LastHandPopup;
	import com.mangogames.views.game.ScoreBoardPopup;
	import com.mangogames.views.popup.AutoDropPopup;
	import com.mangogames.views.popup.ConfirmationPopup;
	import com.smartfoxserver.v2.entities.SFSRoom;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	import feathers.controls.PickerList;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	import utils.Fonts;
	import utils.IMangoCard;
	import utils.ScaleUtils;
	import utils.Sorter;
	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class InGameHud extends Sprite
	{
		private const ShowInjectors:Boolean = false;
		private const SCAN_CARDS_TIME:int	= 5; // 5 seconds 
		
		private var _table:RummyTableView;
		
		private var _btnLeave:Button;
		private var _btnLastHand:Button;
		private var _btnScorecard:Button;
		private var _btnLog:Button;
		private var _btnHistory:Button; // History button
		private var _btnSeqSort:Button;
		private var _btnSetSort:Button;
		private var _btnShow:Button;
		private var _btnDeclare:Button;
		private var _btnDrop:Button;
		private var _btnAutoDrop:Button;
		public 	var btnRebuy:Button; // Rebuy button
		
		private var _lastHand:LastHandPopup;
		private var _scoreBoard:ScoreBoardPopup;
		private var _confirmShowPopup:ConfirmationPopup;
		private var _autoDropPopup:AutoDropPopup; // reference auto drop popup
		private var _historyPopup:HistoryPopup; // Referrence of History popup
		
		private var _optionsContainer:Sprite;
		private var _optionsScreenBtn:Button;
		
		public var _initForSubmit:Boolean;
		
		private var WIDTH:int;
		private var Height:int;
		
		public function InGameHud(table:RummyTableView)
		{
			super();
			
			_table = table;
			_table.gameView.gameovershowcardsSignal.add(onShowCards);
			_table.gameView.showinitiatedSignal.add(onShowInitiated);
			
			var gameScreen:XML 	= MangoAssetManager.I.gameElements;
			var hudPos:XMLList	= gameScreen.theme.hud;
			
			var obj:Object	= AbstractBaseView.getStageSize();
			
			WIDTH		= obj.stageWidth;
			Height		= obj.stageHeight;
			var H_Center:int	= WIDTH/2;
			var V_Center:int	= Height/2;
			
			_optionsScreenBtn	= createButton("", WIDTH - 15, Y, MangoAssetManager.I.getTexture("options_btn"));
			_optionsScreenBtn.scaleX = _optionsScreenBtn.scaleY	= 0.5;
			_optionsScreenBtn.x	= WIDTH - _optionsScreenBtn.width;
			_optionsScreenBtn.y	= (Height - _optionsScreenBtn.height)/2;
			addChild(_optionsScreenBtn);
			_optionsScreenBtn.addEventListener(Event.TRIGGERED, onOptinsBtnClickHandler);
			
			_optionsContainer	= new Sprite();
			_optionsContainer.x	= _optionsScreenBtn.x;
			_optionsContainer.y	= _optionsScreenBtn.y;
			addChild(_optionsContainer);
			
			var X:int			= WIDTH - 300;
			var Y:int			= Height - 40;
			
			// add a button for leave table
			_btnLeave = createButton("LEAVE TABLE", X, Y, MangoAssetManager.I.getTexture("footer_btn"));
			//addChild(_btnLeave);
			_btnLeave.textFormat.size = 14;
			_btnLeave.addEventListener(Event.TRIGGERED, onLeaveTable);
			
			// add a button for last hand
			_btnLastHand = createButton("", 110, 0, MangoAssetManager.I.getTexture("lasthand_btn"));
			ScaleUtils.applyPercentageScale(_btnLastHand, 7, 9);
			_optionsContainer.addChild(_btnLastHand);
			_btnLastHand.textFormat.size 	= 13;
			_btnLastHand.enabled 			= true;
			_btnLastHand.visible			= false;
			_btnLastHand.addEventListener(Event.TRIGGERED, onClickLastHand);
			
			// add a button for scorecard
			_btnScorecard = createButton("",150, -70, MangoAssetManager.I.getTexture("scoreboard_btn"));
			_optionsContainer.addChild(_btnScorecard);
			_btnScorecard.textFormat.size = 12;
			_btnScorecard.visible = false;
			_btnScorecard.addEventListener(Event.TRIGGERED, onClickScoreBoard);
			
			// add a button for history in Point rummy
			if (_table.gameView.room.groupId == "100")
			{
				_btnHistory = createButton("", 150, -70, MangoAssetManager.I.getTexture("history_btn"));
				ScaleUtils.applyPercentageScale(_btnHistory, 7, 9);
				_optionsContainer.addChild(_btnHistory);
				_btnHistory.visible 	= false ; //true;
				_btnScorecard.visible 	= false;
				_btnHistory.textFormat.size 	= 12;
				_btnHistory.addEventListener(Event.TRIGGERED, onClickHistory);
			}
			
			// add a button for scorecard
			_btnLog = createButton("", 150, 60, MangoAssetManager.I.getTexture("log_btn"));
			//_optionsContainer.addChild(_btnLog);
			_btnLog.visible = false;
			_btnLog.addEventListener(Event.TRIGGERED, onLogClickHandler);
			
			_discardedCardButton = new Button(MangoAssetManager.I.getTexture("discards_btn"), "");
			ScaleUtils.applyPercentageScale(_discardedCardButton, 5.5, 8);
			_discardedCardButton.x = 160;
			_discardedCardButton.y = 70;
			_discardedCardButton.visible	= false;
			_optionsContainer.addChild(_discardedCardButton);
			_discardedCardButton.addEventListener(Event.TRIGGERED, onDiscardBtbClickHandler);
			
			// add a button for sort by sequence
			_btnSeqSort = createButton("", H_Center+30, Height-110, MangoAssetManager.I.getTexture("sort_btn"));
			ScaleUtils.applyPercentageScale(_btnSeqSort, 10, 7);
			_btnSeqSort.x	=  WIDTH/2 + _btnSeqSort.width;
			_btnSeqSort.y	= Height/2 + _btnSeqSort.height*1.3;
			
			addChild(_btnSeqSort);
			_btnSeqSort.enabled = false;
			_btnSeqSort.addEventListener(Event.TRIGGERED, function(event:Event):void
			{
				var handCards:Vector.<Vector.<IMangoCard>> = _table.meldArea.toIMangoCardGroups();
				handCards = Sorter.sortBySequence(handCards, _table.dealImpl.joker.card.rank);
				_table.meldArea.populate(handCards);
			});
			
			// not using this
			_btnSetSort = createButton("", hudPos.setSort.@x, hudPos.setSort.@y, MangoAssetManager.I.getTexture("Set one"));
			//addChild(_btnSetSort);
			_btnSetSort.enabled = false;
			_btnSetSort.addEventListener(Event.TRIGGERED, function(event:Event):void
			{
				var handCards:Vector.<Vector.<IMangoCard>> = _table.meldArea.toIMangoCardGroups();
				handCards = Sorter.sortBySets(handCards, _table.dealImpl.joker.card.rank);
				_table.meldArea.populate(handCards);
			});
			
			// add a button for show
			_btnShow = createButton("", 0, Height-60, MangoAssetManager.I.getTexture("show_btn"));
			ScaleUtils.applyPercentageScale(_btnShow, 10, 7);
			_btnShow.x	= WIDTH - _btnShow.width*2;
			_btnShow.y	= Height/2 + _btnShow.height;
			addChild(_btnShow);
			_btnShow.visible = false;
			_btnShow.textFormat.size = 15;
			_btnShow.addEventListener(Event.TRIGGERED, onInitShow);
			
			// add a button for declare
			_btnDeclare = createButton("", WIDTH-250, Height-60, MangoAssetManager.I.getTexture("declare_btn"));
			ScaleUtils.applyPercentageScale(_btnDeclare, 10, 7);
			_btnDeclare.x	= WIDTH - _btnDeclare.width*2;
			_btnDeclare.y	= Height/2 + _btnDeclare.height*1.3;
			addChild(_btnDeclare);
			_btnDeclare.visible = false;
			_btnDeclare.textFormat.size = 15;
			_btnDeclare.addEventListener(Event.TRIGGERED, onInitDeclare);
			
			// add a button for drop
			_btnDrop = createButton("", 0, 0, MangoAssetManager.I.getTexture("drop_btn"));
			ScaleUtils.applyPercentageScale(_btnDrop, 10, 7);
			_btnDrop.x	= WIDTH/2 - _btnDrop.width*3;
			_btnDrop.y	= Height/2 + _btnDrop.height*1.3;
			addChild(_btnDrop);
			
			_btnDrop.addEventListener(Event.TRIGGERED, onDrop);
			
			_btnAutoDrop = createButton("Auto Drop", 0, 0, MangoAssetManager.I.getTexture("footer_btn"));
			addChild(_btnAutoDrop);
			_btnAutoDrop.width = _btnDrop.width;
			_btnAutoDrop.height= _btnDrop.height;
			_btnAutoDrop.x		= _btnDrop.x;
			_btnAutoDrop.y		= _btnDrop.y;
			_btnAutoDrop.addEventListener(Event.TRIGGERED, onAutoDrop);
				
			_btnAutoDrop.visible = false;
			
			btnRebuy = createButton("Rebuy", hudPos.rebuy.@x, hudPos.rebuy.@y, MangoAssetManager.I.getTexture("RED"), MangoAssetManager.I.getTexture("RED"));
			//addChild(btnRebuy);
			btnRebuy.visible = false;
			btnRebuy.addEventListener(Event.TRIGGERED, onRebuyBtn);

			_btnReport = createButton("Report", gameScreen.theme.report.@x, gameScreen.theme.report.@y, MangoAssetManager.I.getTexture("RED"), MangoAssetManager.I.getTexture("RED"));
			//addChild(_btnReport);
			_btnReport.addEventListener(Event.TRIGGERED, onReportBtn);
			
			// drop is not allowed for Best of 2 and 3 games.
			// HACK: lame way to implement it
			var gameType:String = GameStatsView.getRoomNameStringByGroupId(_table.gameView.room);
			if (gameType == "Best of 2" || gameType == "Best of 3")
			{
				_btnDrop.visible = false;
				_btnAutoDrop.visible = false;
			}
			
			if (ShowInjectors)
				cardInjectors();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onDiscardBtbClickHandler():void
		{
			_table.gameView.showDiscardsPopupSignal.dispatch();
		}
		
		private function onLogClickHandler():void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function onOptinsBtnClickHandler(event:Event):void
		{
			var tween:Tween = new Tween(_optionsContainer, 0.3, Transitions.EASE_IN_OUT);
			var scaleTo:int;
			var xPos:int;
			if(_optionsContainer.x >= _optionsScreenBtn.x)
			{
				scaleTo	= 1;
				xPos	= _optionsContainer.x - 200; 
			}
			else
			{
				scaleTo	= 0.1;
				xPos	= _optionsScreenBtn.x + _optionsScreenBtn.width/2; 
			}
			
			tween.moveTo(xPos, _optionsContainer.y);
			tween.scaleTo(scaleTo)
			Starling.juggler.add(tween);
			
			if (_table.gameView.room.groupId == "100")
			{
				_btnHistory.visible 		= true;
				_btnScorecard.visible		= false;
			}
			else
			{
				if(_btnHistory) _btnHistory.visible		= false;
				_btnScorecard.visible 		= true;
			}
			_btnLastHand.visible			= true;
			_btnLog.visible					= true;
			_discardedCardButton.visible	= true;
		}
		
		public function removePopupsIfAny():void
		{
			if (PopUpManager.isPopUp(_scoreBoard))
				PopUpManager.removePopUp(_scoreBoard);
				
			if(PopUpManager.isPopUp(_leavePopup))
				PopUpManager.removePopUp(_leavePopup);
			
			if(PopUpManager.isPopUp(_lastHand))
			{
				PopUpManager.removePopUp(_lastHand);
				_lastHand	= null;
			}
			
			if (_historyPopup)
				_table.removeChild(_historyPopup);
				
		}
		
		public function onRebuyBtn():void
		{
			//_table.gameView.buyinSignal.dispatch(false);
			_table.onRebuyBuyIn();
		}
		
		public function onReportBtn():void
		{
			/*var jpgEncoder:JPEGEncoder = new JPEGEncoder();
			
			var bitmapData:BitmapData = new BitmapData(stage.width, stage.height);
			stage.drawToBitmapData(bitmapData);
			
			var img:ByteArray =  jpgEncoder.encode(bitmapData);
			
			var b64:Base64Encoder = new Base64Encoder();
			b64.encodeBytes(img);*/
			
			var serverURL:URLRequest = new URLRequest("http://10.1.0.189:3000/admins/send_game_error");
			var variables:URLVariables = new URLVariables();
			
			variables.gameId = _table.gameView.room.id;
			variables.playerId = 100;
			variables.userName = (_table.mySeat.seatImpl && _table.mySeat.seatImpl.player) ? _table.mySeat.seatImpl.player.name : null;
			variables.issueTitle = "Title Issue";
			variables.description = "Issue Description";
			//variables.image = b64;
			
			serverURL.method = URLRequestMethod.POST;
			serverURL.data = variables;
			
			var URLLoad:URLLoader = new URLLoader();   
			URLLoad.addEventListener( Event.COMPLETE, onComplete );
			URLLoad.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			URLLoad.load(serverURL);
		}
		
		public function onDisableLeaveBtn():void
		{
			_btnLeave.enabled = false;
			if(_leavePopup)
			{
				PopUpManager.removePopUp(_leavePopup);
				_leavePopup			= null;
			}
		}
		public function onEnableLeaveBtn():void
		{
			_btnLeave.enabled = true;
		}
		
		public function autoDropButtonVisible(value:Boolean):void
		{
			var gameType:String = GameStatsView.getRoomNameStringByGroupId(_table.gameView.room);

			if (gameType == "Best of 2" || gameType == "Best of 3")
				_btnAutoDrop.visible = false;
			else
				_btnAutoDrop.visible = value; 
		}
		
		public function disableDropAndAutoDropBtns():void
		{
			if(_btnAutoDrop ) _btnAutoDrop.visible 	= false;
			if(_btnDrop) 	_btnDrop.enabled	 	= false;
		}
		
		override public function dispose():void
		{			
			if (_lastHand)
				_lastHand.dispose();
			
			if (_scoreBoard)
				_scoreBoard.dispose();
			
			if (_historyPopup)
				_historyPopup.dispose();
			_table.isShowProcessed	= false;
			
			isFinalSubmission	= false;
			_isPlayerDropped	= false;
			
			super.dispose();
		}
		
		private function onEnterFrame(event:Event):void
		{
			if(_table.isSpectator)
			{
				_btnSeqSort.visible	= false;
				_btnDrop.visible	= false;
				_btnAutoDrop.visible= false;
				_btnReport.visible	= false;
				if(_btnHistory) _btnHistory.visible	= false;
				_btnLeave.visible	= true;
				_btnLeave.enabled	= true;
			}
			else
			{
				_btnSeqSort.enabled = _table.meldArea.isHandCardsAvailable && !_table.aboutToDeclare;
				_btnSetSort.enabled = _table.meldArea.isHandCardsAvailable && !_table.aboutToDeclare;
				_btnDrop.enabled 	= _table.canDrop;
				
				// disable the sort button when user drops
				if(_table.matchImpl)
					_btnSeqSort.enabled	= !_table.isDropped;
				// disable the srot button when user submitted their cards
				if(_table.meldArea.isSubmitted)
					_btnSeqSort.enabled		= false;
				
				if (!_initForSubmit)
				{
					_btnShow.visible = _table.canDeclare && !_table.aboutToDeclare;
					_btnShow.enabled	= true;
				}
				
				if(_table.isJoinedFromMyTable && _table.isForceShowBtnEnable && _table.canDrop)
				{
					_btnShow.visible	= true;
				}
				// overriding for myTable player
				if(_table.isMyTablePlayerDropped)
					_btnSeqSort.enabled	= false;
				
				if(isFinalSubmission)
					_btnShow.enabled	= false;
			}
		}
		
		private function onInitShow(event:Event):void
		{
			if (_table.meldArea.newReceivedCard)
			{
				_table.isForceShowBtnEnable	= false
				var message:String = "Do you want to show?";
				PopUpManager.root = _table.gameView;
				_confirmShowPopup = ConfirmationPopup(PopUpManager.addPopUp(new ConfirmationPopup("SHOW", message, onOk, onCancel)));
				
				_table.isShowProcessed	= true;
				function onOk():void
				{
					// checking .. if the player clicked Ok Btn within his turn timer or not ?
					var isValid:Boolean	= _table.checkingForValidShow();
					if(isValid)
					{
						_btnShow.visible 			= false;
						_btnDeclare.visible 		= true;
						_table.isGamePaused 		= true;
						_isDeclared					= false
						_table.prepareToDeclare();
					}
				}
				
				function onCancel():void
				{
					_table.isShowProcessed	= false;
				}
			}
		}
		
		public function showDeclareBtn():void
		{
			_btnDeclare.visible	= true;
		}
		public function disableDeclareBtn():void
		{
			_btnDeclare.visible	= false;
		}
		
		private function onInitDeclare(event:Event=null):void
		{
			if(event)
			{
				_isFinalDeclare	= true;
				if(_scanDeclareTimer)
				{
					_scanDeclareTimer.stop();
					_scanDeclareTimer.removeEventListener(TimerEvent.TIMER, scanCardsAndDeclare);
					_scanDeclareTimer	= null;
				}
			}
				
			_isDeclared	= true;
			_table.meldArea.declareCards(_isFinalDeclare);
			_table.isGamePaused = false;
			if(_isFinalDeclare) 	_btnDeclare.visible = false;
		}
		
		private function onClickScoreBoard(event:Event):void
		{
			if(_table.matchImpl)
			{
				if (!_scoreBoard)
					_scoreBoard = new ScoreBoardPopup(_table.matchImpl);
				
				_scoreBoard.refresh(_table.gameImpl, _table.matchImpl, _table.dealImpl);
				
				if (!PopUpManager.isPopUp(_scoreBoard))
				{
					PopUpManager.root = _table.gameView;
					PopUpManager.addPopUp(_scoreBoard);
				}
			}
		}
		
		private function onClickHistory(event:Event):void
		{
			if (!_historyPopup)
			{
				_historyPopup = new HistoryPopup();
				_historyPopup.x = (WIDTH - _historyPopup.width)/2;
				_historyPopup.y = (Height - _historyPopup.height)/2;
			}
			_historyPopup.refresh(_table.history, _table.historyGameId);
		
//			if (!PopUpManager.isPopUp(_historyPopup))
//			{
				//PopUpManager.root = _table.gameView;
			if (_table.history.length != 0)
				_table.addChild(_historyPopup)
				//PopUpManager.addPopUp(_historyPopup);
			//}
		}
		
		public function refreshHistoryPopup():void
		{
			if (_historyPopup)
				_historyPopup.refresh(_table.history, _table.historyGameId);
		}
		
		
		
		private function onClickLastHand(event:Event):void
		{
			ProxySignals.getInstance().toggleChatWindowSignal.dispatch(true, _table.gameView.room.id);
			showLastHand(-1);
		}
		
		private function onShowInitiated(seatId:int, timeout:int):void
		{
			_scanCountForDeclare	=0;
			if(seatId == _table._mySeatId)
			{
				_scansToBeDone	= timeout/SCAN_CARDS_TIME;
				_scanDeclareTimer	= new Timer(SCAN_CARDS_TIME*1000, _scansToBeDone);
				_scanDeclareTimer.addEventListener(TimerEvent.TIMER, scanCardsAndDeclare);
				_scanDeclareTimer.start();
			}
		}
		
		private function scanCardsAndDeclare(event:TimerEvent):void
		{
			_scanCountForDeclare++;
			if(_scanCountForDeclare == _scansToBeDone)
			{
				_isFinalDeclare	= true;
				_scanDeclareTimer.stop();
				_scanDeclareTimer.removeEventListener(TimerEvent.TIMER, scanCardsAndDeclare);
				_scanDeclareTimer	= null;
			}
			onInitDeclare();
		}
		
		private function onShowCards(seatId:int, timeout:int, score:int, leftPlayers:SFSArray, handCards:HandCardsImpl, totScore:int):void
		{
			if(seatId != _table._mySeatId)
			{
				_scanedCount	= 0;
				_scansToBeDone	= timeout/SCAN_CARDS_TIME;
				_totalTimer	= new Timer(SCAN_CARDS_TIME*1000, _scansToBeDone);
				_totalTimer.addEventListener(TimerEvent.TIMER, scanCardsAndSend);
				_totalTimer.start();
			}
			else
			{
				// disable the declare button if there , as the player done with auto declare 
				if(_btnDeclare)
					_btnDeclare.visible	= false;
			}
		}
		
		protected function scanCardsAndSend(event:TimerEvent):void
		{
			_scanedCount++;
			if(_scanedCount == _scansToBeDone)
			{
				onSubmittedSetValues();
				//_initForSubmit = true;
				isFinalSubmission	= true;
			}
			var handCards:HandCardsImpl	= _table.meldArea.getHandCardsWithSelctedCards();
			
			SFSInterface.getInstance().submit(handCards, _table.gameView.room, false);
		}
		
		private function onSubmit(event:Event=null):void
		{
			onSubmittedSetValues();
			//setForDeclare();
			SFSInterface.getInstance().submit(_table.meldArea.getHandCardsWithSelctedCards(), _table.gameView.room, true);
		}
		
		private function onSubmittedSetValues():void
		{
			trace("FINAL AUTO SUBMITION *******************");
			// don't scan cards , when user submitted their cards
			removeScanCards();
			_initForSubmit = false;
			_btnShow.visible = false;
			_table.meldArea.isSubmitted	= true;
			
			_table.meldArea.addOutsideDraggedCard();
			// removing addhere button if any
			_table.meldArea.removeAddHereButtonsIfAny();
		}
		
		private function removeScanCards():void
		{
			if(_totalTimer)
			{
				_totalTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, scanCardsAndSend);
				_totalTimer.stop();
				_totalTimer	= null;
			}
		}
		
		private function onDrop(event:Event):void
		{			
			var message:String = "Do you want to drop?";
			PopUpManager.root = _table.gameView;
			_confirmShowPopup = ConfirmationPopup(PopUpManager.addPopUp(new ConfirmationPopup("DROP", message, onOk, onCancel)));
			
			_table.meldArea.removeAddHereButtonsIfAny();
			_table.meldArea.disableGroupBtnsIfAny();
			function onOk():void
			{
				_table.meldArea.fold();
				Starling.juggler.delayCall(fold, 0.2);
				
				function fold():void
				{
					_isPlayerDropped	= true;
					SFSInterface.getInstance().dropMe(_table.gameView.room);
				}
			}
			
			function onCancel():void
			{
				// nothing to do
			}
		}
		
		private function onComplete(event:Event):void
		{
			
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			
		}
		
		public function autoDropAfterTurn():void
		{
			autoDropButtonVisible(false);
			_table.meldArea.fold();
			Starling.juggler.delayCall(fold, 0.2);
			
			function fold():void
			{
				_isPlayerDropped	= true;
				SFSInterface.getInstance().dropMe(_table.gameView.room);
			}
		}
		
		private function onAutoDrop(event:Event):void
		{
			// Show a string and a popup
			_table.isAutoDrop = true;
				PopUpManager.root = _table.gameView;
			_autoDropPopup = AutoDropPopup(PopUpManager.addPopUp(new AutoDropPopup(_table)));
		}
		
		public function removeAutoDropPopup():void
		{
			if (_autoDropPopup && PopUpManager.isPopUp(_autoDropPopup))
				PopUpManager.removePopUp(_autoDropPopup);
			
			_autoDropPopup = null;
		} 
		
		private function onLeaveTable(event:Event):void
		{
			var message:String = "Do you really want to leave this table?";
			PopUpManager.root = _table.gameView;
			_leavePopup		  = new ConfirmationPopup("LEAVE TABLE", message, onOk, onCancel);
			PopUpManager.addPopUp(_leavePopup);
			
			function onOk():void
			{
				if(_table.isMiddleJoin || _table.isSpectator)
				{
					tableCleanUp();
				}
				else if(_table.matchImpl)
				{
					if((_table.gameImpl is BestOfNGameImpl) && _table.playersCount==1) 
						tableCleanUp();
					else
						SFSInterface.getInstance().dropMe(_table.gameView.room, true, _isPlayerDropped);
				}
				else
				{
					tableCleanUp();
				}
			}
			
			function onCancel():void
			{
				// nothing to do here
			}
		}
		
		private function tableCleanUp():void
		{
			var room:SFSRoom = _table.gameView.room;
			
//			var roomVar:RoomVariable = room.getVariable("Player");
//			var players:Array	 = room.playerList;
//			if(players.length >0)
//			{
//				SFSInterface.getInstance().setUserVariables("isLeaveTable", true);
//			}
			
			//SFSInterface.getInstance().updateRoomVariable("leavetable", true);
			
			_table.dispose();
			_table.cleanup();
			SFSInterface.getInstance().closeRoom(_table.gameView.room.id, true);
		}
		
		public function toggleScorecardButton(value:Boolean, enableLastHand:Boolean):void
		{
			_btnLastHand.enabled = enableLastHand;
			_btnScorecard.enabled = value;
		}
		
		public function showSettlementBoard(autoCloseTime:int):void
		{
			var mySeat:SeatView;
			var myId:int;
			
			if(_table._settlementPopup) 
			{
				_table._settlementPopup.closeAfterSeconds(autoCloseTime);
				
				// pushing the info to show the Lasthand Popup , if user clicks on Last Hand Btn
				if (_table.gameImpl is PointsGameImpl)
				{
					_lastHand.setForPoint(autoCloseTime == -1, _table.gameView.room.getVariable("Bet").getIntValue());
					_table._settlementPopup.setForPoint(false, _table.gameView.room.getVariable("Bet").getIntValue())
				}
				else
				{
					_lastHand.setForPool(autoCloseTime == -1);
					_table._settlementPopup.setForPool(false);
				}
				
				mySeat = _table.mySeat;
				myId = mySeat && mySeat.seatImpl && mySeat.seatImpl.player ? mySeat.seatImpl.player.id : -1;
				//_lastHand.refresh(_table.settlement, _table.gameImpl, _table.gameView,  (_table.dealImpl && _table.dealImpl.joker)?_table.dealImpl.joker.card:_table.joker, myId);
			}
		}
		
		public function showLastHand(autoCloseTime:int):void
		{
			_table.removeExtraPopups();
			removePopupsIfAny();
			
			if (!_lastHand)
			{
				_lastHand = new LastHandPopup(_table);
			}
					
			if (!PopUpManager.isPopUp(_lastHand))
			{
				var mySeat:SeatView;
				var myId:int;
				
				if (PopUpManager.isPopUp(_scoreBoard))
					PopUpManager.removePopUp(_scoreBoard);
					
				else if(PopUpManager.isPopUp(_leavePopup))
					PopUpManager.removePopUp(_leavePopup);
				
				PopUpManager.root = _table.gameView;
				if(_table._settlementPopup) 
				{
					//_table._settlementPopup.refresh(
					_table._settlementPopup.closeAfterSeconds(autoCloseTime);
				}
				
				if(_lastHand)
				{
					if (_table.gameImpl is PointsGameImpl)
						_lastHand.setForPoint(autoCloseTime == -1, _table.gameView.room.getVariable("Bet").getIntValue());
					else
						_lastHand.setForPool(autoCloseTime == -1);
				}
				if (_lastHand && !_table._settlementPopup)
				{
					mySeat = _table.mySeat;
					myId = mySeat && mySeat.seatImpl && mySeat.seatImpl.player ? mySeat.seatImpl.player.id : -1;
					_lastHand.refresh(_table.settlement, _table.gameImpl, _table.gameView,  (_table.dealImpl && _table.dealImpl.joker)?_table.dealImpl.joker.card:_table.joker, myId);
					
					PopUpManager.addPopUp(_lastHand, true, true);
					_lastHand.closeAfterSeconds(autoCloseTime);
				}
				else
				{
					if(_lastHand)
						_lastHand.removeAllHighlights();
				}
				//}
			}
			
		}
		
		public function disableSubmitBtn():void
		{
			_btnShow.visible	= false;
		}
		
		public function setForSubmit():void
		{
			var texture:Texture = MangoAssetManager.I.getTexture("submit_btn");
			var downTexture:Texture = MangoAssetManager.I.getTexture("submit_btn");
			_btnShow.upState = texture;
			_btnShow.downState = downTexture;
			_btnShow.width = texture.width;
			_btnShow.height = texture.height;
			
			_initForSubmit = true;
			_btnScorecard.enabled = false;
			_btnShow.visible = true;
			isFinalSubmission	= false;
			_isFinalDeclare	= false;
			_btnShow.text = "";
			_btnShow.removeEventListener(Event.TRIGGERED, onInitShow);
			_btnShow.addEventListener(Event.TRIGGERED, onSubmit);
		}
		
		public function setForDeclare():void
		{
			var texture:Texture = MangoAssetManager.I.getTexture("show_btn");
			var downTexture:Texture = MangoAssetManager.I.getTexture("show_btn");
			
			_btnShow.upState = texture;
			_btnShow.downState = texture;
			_btnShow.width = texture.width/2;
			_btnShow.height = texture.height/2;
			
			_initForSubmit = false;
			_btnDeclare.visible = false;
			_btnShow.visible = false;
			isFinalSubmission	= false;
			_isFinalDeclare	= false;
			_btnShow.text = "";
			_btnShow.addEventListener(Event.TRIGGERED, onInitShow);
			_btnShow.removeEventListener(Event.TRIGGERED, onSubmit);
		}
		
		public function removeConfirmShowPopup():void
		{
			if (_confirmShowPopup && PopUpManager.isPopUp(_confirmShowPopup))
				PopUpManager.removePopUp(_confirmShowPopup);
			
			_confirmShowPopup = null;
		}
		
		public function updateSettlementPopupTime(time:int):void
		{
			_lastHand.updateCloseTime(time);
		}
		
		public function enableManualSplit(splitAmounts:Array):void
		{
			_lastHand.enableManualSplit(splitAmounts);
		}
		
		public function setSplitAcceptedForPlayer(playerId:int, value:Boolean):void
		{
			_lastHand.setSplitAcceptedForPlayer(playerId, value);
		}
		
		
		// -----------------------------------------------------
		// --injectors------------------------------------------
		// -----------------------------------------------------
		private var _suitList:PickerList;
		private var _rankList:PickerList;
		private var _leavePopup:ConfirmationPopup;
		private var _totalTimer:Timer;
		private var _scansToBeDone:int;
		private var _scanedCount:int;
		public var _isPlayerDropped:Boolean;
		private var _isDeclared:Boolean;
		public var isFinalSubmission:Boolean;
		private var _btnReport:Button;
		private var _scanCountForDeclare:int;
		private var _scanDeclareTimer:Timer;
		private var _isFinalDeclare:Boolean;
		private var _discardedCardButton:Button;
		
		private function cardInjectors():void
		{
			// add a button injecting a predefined set of cards
			var button:Button = createButton("INJECT HAND CARDS", 400, 20);
			addChild(button);
			button.addEventListener(Event.TRIGGERED, onClickIntechHandCards);
			
			// remove button
			button = createButton("REMOVE SELECTED", 600, 20);
			addChild(button);
			button.addEventListener(Event.TRIGGERED, function (event:Event):void
			{
				_table.meldArea.removeSelectedCards();
			});
			
			// drop down list for suit
			_suitList = new PickerList();
			addChild(_suitList);
			_suitList.x = 400;
			_suitList.y = 60;
			_suitList.dataProvider = new ListCollection([ "Heart", "Spade", "Diamond", "Club", "Paper Joker" ]);
			
			// drop down list for ranks
			_rankList = new PickerList();
			addChild(_rankList);
			_rankList.x = 500;
			_rankList.y = 60;
			_rankList.dataProvider = new ListCollection([ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" ]);
			
			// add button
			button = createButton("INJECT", 600, 60);
			addChild(button);
			button.addEventListener(Event.TRIGGERED, onClickInject);
		}
		
		private function onClickIntechHandCards(event:Event):void
		{
			RummyTableView(_table).setJoker();
			_table.meldArea.setHandCards(getHandCards());
		}
		
		private function onClickInject(event:Event):void
		{
			var cardImpl:CardImpl = new CardImpl();
			if (_suitList.selectedIndex == 4)
			{
				cardImpl.rank = 0;
				cardImpl.ispaperjoker = 2;
			}
			else
			{
				cardImpl.suit = _suitList.selectedIndex;
				cardImpl.rank = _rankList.selectedIndex;
			}
			_table.meldArea.injectCard(cardImpl);
		}
		
		public static function getHandCards():HandCardsImpl
		{
			var handCards:HandCardsImpl = new HandCardsImpl();
			
			for (var suit:int = 0; suit < 4; suit++)
			{
				var groupCards:GroupCardsImpl = new GroupCardsImpl();
				
				// create pure sequences
				for (var rank:int = 0; rank < 3; rank++)
				{
					var card:CardImpl = new CardImpl();
					card.rank = rank;
					card.suit = suit;
					groupCards.card.push(card);
				}
				handCards.groupcards.push(groupCards);
			}
			
			// one last card to make it 13 cards
			card = new CardImpl();
			card.rank = rank;
			card.suit = suit - 1;
			groupCards.card.push(card);
			
			return handCards;
		}
		
		private static function createButton(label:String, posX:int, posY:int, texture:Texture = null, downTexture:Texture = null):Button
		{
			var button:Button = new Button(texture ||= MangoAssetManager.I.getTexture("footer_btn"), label, downTexture);// "gamebtn"
			/*button.scaleX	= 0.5;
			button.scaleY	= 0.5;*/
			button.textFormat.font = "verdana"
			button.textFormat.bold = true;
			button.textFormat.color = Fonts.getInstance().colorWhite;
			button.textFormat.size = 12;
			button.x = posX;
			button.y = posY;
			button.textFormat.horizontalAlign	= "center";
			button.textFormat.verticalAlign		= "center";
			return button;
		}
		
		public function disableSortBtn():void
		{
			_btnSetSort.enabled	= false;
			_btnSeqSort.enabled	= false;
		}
	}
}