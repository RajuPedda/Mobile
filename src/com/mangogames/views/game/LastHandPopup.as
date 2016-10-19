package com.mangogames.views.game
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.models.IGame;
	import com.mangogames.rummy.model.impl.BestOfNGameImpl;
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.GroupCardsImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.MatchSettlementImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.PlayerSettlementImpl;
	import com.mangogames.rummy.model.impl.SyndicateGameImpl;
	import com.mangogames.rummy.model.util.GameUtil;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.AbstractBaseView;
	import com.mangogames.views.game.tableview.CardView;
	import com.mangogames.views.game.tableview.InGameHud;
	import com.mangogames.views.game.tableview.SeatView;
	import com.mangogames.views.game.tableview.TableView;
	import com.mangogames.views.popup.ConfirmationPopup;
	
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.core.PopUpManager;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import utils.Ace2JakCard;
	import utils.Fonts;
	import utils.PlayerState;
	import utils.ScaleUtils;
	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class LastHandPopup extends Sprite
	{
		private var _table:TableView;
		private var _closeTimer:Timer;
		private var _timerLabel:TextField;
		private var _scrollList:ScrollContainer;
		private var _btnClose:Button;
		private var _btnToLobby:Button;
		private var _btnOk:Button;
		private var _btnManualSplit:Button;
		
		private var _lblHeader:TextField;
		private var _lblBetAmount:TextField;
		private var _lblScoreOrCount:TextField;
		private var _lblWinLoseOrTotal:TextField;
		private var _forPoint:Boolean;
		private var _isLast:Boolean;
		private var _splitAmounts:Array;
		
		private var _joker:Ace2JakCard;
		private var _Height:int;
		private var _Width:int;
		private var _headerBg:Image;
		private var _popupBg:Image;
		
		public function LastHandPopup(table:TableView)
		{
			_table = table;
			
			var obj:Object	= AbstractBaseView.getStageSize();
			_Width		= obj.stageWidth;
			_Height		= obj.stageHeight;
			
			var bgTexture:Texture	= MangoAssetManager.I.getTexture("score_board_popup");
			_popupBg	= new Image(bgTexture);
			_popupBg.scale9Grid	= new Rectangle( 10, 20, 60, 60 );
			_popupBg.width 		= _Width - _Width/40;
			_popupBg.height 	= _Height - _Width/40;
			_popupBg.y			= 8;
			_popupBg.x			= 8;
			this.addChild( _popupBg );
			
			_headerBg 	= new Image(MangoAssetManager.I.getTexture("scoreBoard_header_bg"));
			_headerBg.x			= _Width/30;
			_headerBg.y			= _Height/12;
			_headerBg.width		= _Width - _Width/14; //_Width -130;
			_headerBg.height	= _Height/16; //30;
			addChild(_headerBg);
			
			initHeader();
			initSettlement();
			initToLobbyButton();
			
			_btnManualSplit = new Button(MangoAssetManager.I.getTexture("split_btn"), "");
			addChild(_btnManualSplit);
			_btnManualSplit.x = _popupBg.width - _btnManualSplit.width - 20;
			_btnManualSplit.y = _popupBg.height
			_btnManualSplit.addEventListener(Event.TRIGGERED, onClickManualSplit);
			_btnManualSplit.visible = false;
		}
		
		private function initSettlement():void
		{
			_scrollList = new ScrollContainer();
			_scrollList.verticalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_scrollList.elasticity = 0;
			_scrollList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FIXED;
			var layout:VerticalLayout = new VerticalLayout();
			layout.gap = 1;
			
			_scrollList.layout = layout;
			_scrollList.x =  _Width/30;
			_scrollList.y =  _Height/6.35;
			_scrollList.width = _Width-_scrollList.x;
			_scrollList.height = _Height -_scrollList.y;
			
			addChild(_scrollList);
			
			//refreshScore();
		}
		
		override public function dispose():void
		{
			if(_closeTimer) _closeTimer.removeEventListener(TimerEvent.TIMER, onCloseTimerTick);
			_scrollList.removeChildren(0, -1, true);
			_scrollList.removeFromParent(true);
			_btnClose.removeEventListener(Event.TRIGGERED, onClickClose);
			_btnToLobby.removeEventListener(Event.TRIGGERED, onClickToLobby);
			removeChildren(0, -1, true);
		}
		
		private var _resultLabel:TextField;
		private var _nameLabel:TextField;
		private var _rowBg:Image;
		
		private function initHeader():void
		{
			_lblHeader = createLabel();
			_lblHeader.text = "Last Hand -" +_table.lastGameId ;
			_lblHeader.format.size = 12;
			addChild(_lblHeader);
			_lblHeader.x = 70;
			_lblHeader.y = 10;
			
			_lblBetAmount = createLabel();
			_lblBetAmount.text = "Bet: ";
			_lblBetAmount.format.size = 12;
			addChild(_lblBetAmount);
			_lblBetAmount.x = _Width-160;//780;
			_lblBetAmount.y = 10;
			
			_nameLabel = createLabel();
			_nameLabel.text = "Name";
			addChild(_nameLabel);
			_nameLabel.x = _headerBg.x+_nameLabel.width/2; 
			_nameLabel.y = _headerBg.y+ (_headerBg.height-_nameLabel.height)/2; 
			
			_resultLabel = createLabel()
			_resultLabel.text = "Result";
			addChild(_resultLabel);
			_resultLabel.x = _headerBg.width/4 - _resultLabel.width*1.5; //150 + (90 - result.width) / 2;
			_resultLabel.y =_headerBg.y+ (_headerBg.height-_resultLabel.height)/2;
			
			var cards:TextField = createLabel();
			cards.text = "Cards";
			addChild(cards);
			cards.x =_Width/2 - cards.width / 2-15;
			cards.y = _headerBg.y+ (_headerBg.height-cards.height)/2;
			
			_lblScoreOrCount = createLabel();
			_lblScoreOrCount.text = "Score";
			addChild(_lblScoreOrCount);
			_lblScoreOrCount.x = _Width-425;//760;
			_lblScoreOrCount.y = _headerBg.y+ (_headerBg.height-_lblScoreOrCount.height)/2;
			
			_lblWinLoseOrTotal = createLabel();
			_lblWinLoseOrTotal.text = "Total";
			addChild(_lblWinLoseOrTotal);
			_lblWinLoseOrTotal.x = _Width-375;//860;
			_lblWinLoseOrTotal.y = _headerBg.y+ (_headerBg.height-_lblWinLoseOrTotal.height)/2;
			
			// add a close button which will be hidden by default
			_btnClose = new Button(MangoAssetManager.I.getTexture("close_btn"), "");
			addChild(_btnClose);
			_btnClose.x = _popupBg.width - _btnClose.width - 5;
			_btnClose.y = 10;
			_btnClose.addEventListener(Event.TRIGGERED, onClickClose);
			_btnClose.visible = false;
		}
		private function createRowForPlayer(playerSettlement:PlayerSettlementImpl, game:IGame, joker:CardImpl, winnerId:int):Sprite
		{
			var row:Sprite = new Sprite();
			var player:PlayerImpl = GameUtil.getPlayerBySeatId(game, playerSettlement.seatId);
			row.name = player?player.id.toString():null;
			
			// row bg
			_rowBg 				= new Image(MangoAssetManager.I.getTexture("scoreBoard_Body_Bg"));
			_rowBg.width		= _Width - _Width/14;
			_rowBg.x			= 0;
			_rowBg.y			= 0;
			row.addChild(_rowBg);
			
			// split-accepted overlay, hidden by default
			var greenOverlay:Quad	= new Quad(_Width, 67, 0x529e1b);
			greenOverlay.alpha		= 0.3;
			greenOverlay.name 		= player?player.id.toString():"";
			greenOverlay.visible 	= false;
			//row.addChild(greenOverlay);
			
			// name
			var label:TextField = createLabel();
			label.alignPivot("left", "center");
			label.text = player && player.name ? player.name : "null";
			row.addChild(label);
			label.x = _nameLabel.x - _nameLabel.width; ////+ (_nameLabel.width - label.width)/2; ///8 + (90 - label.width) / 2;
			label.y = _rowBg.y+ (_rowBg.height-label.height)/2+10; //0 + (65 - label.height) / 2;
			
			// result
			var result:TextField = createLabel();
			result.alignPivot("left", "center");
			result.text = PlayerState.toString(playerSettlement.state);
			row.addChild(result);
			result.x = _resultLabel.x - _resultLabel.width+10; //- (_resultLabel.width- result.width)/2; ///105 + (90 - label.width) / 2;
			result.y = label.y;
			
			var winner_star:Image	= new Image(MangoAssetManager.I.getTexture("winner_star"));
			row.addChild(winner_star);
			winner_star.name		= "winnerStar";
			winner_star.x			= label.x+5;
			winner_star.y			= label.y-18;
			winner_star.visible		= label.text=="Winner"?true:false;
			
			// cards
			if (playerSettlement.state != PlayerState.DROPPED &&
				playerSettlement.state != PlayerState.FIRST_DROP &&
				playerSettlement.state != PlayerState.MIDDLE_DROP)
			{
				var cardContainer:Sprite = createHandCards(playerSettlement.handCards, joker);
				row.addChild(cardContainer);
				cardContainer.x = (_rowBg.width-cardContainer.width)/2;
				cardContainer.y = 2;
			}
			
			// count/game score
			var countOrScore:TextField = createLabel();
			countOrScore.text = playerSettlement.currentScore.toString();
			
			row.addChild(countOrScore);
			countOrScore.x = _lblScoreOrCount.x; // _Width-320+ (105 - countOrScore.width) / 2;
			countOrScore.y = _rowBg.y+ (_rowBg.height-countOrScore.height)/2;
			
			// win-lose/total score
			var wonOrLose:TextField = createLabel();
			wonOrLose.text = _forPoint
				? (playerSettlement.playerId == winnerId ? "+" : "-") + Number(playerSettlement.wonorloss / 100).toFixed(2).toString()
				: playerSettlement.totalScore.toString();
			row.addChild(wonOrLose);
			wonOrLose.x =  _lblWinLoseOrTotal.x; 
			wonOrLose.y = _rowBg.y+ (_rowBg.height-wonOrLose.height)/2;
			
			return row;
		}
		
		private function initToLobbyButton():void
		{
			_btnToLobby = new Button(MangoAssetManager.I.getTexture("leavetable_btn_02"), "");
			addChild(_btnToLobby);
			_btnToLobby.x = _Width-200;//810;
			_btnToLobby.y = _Height-92//665;
			_btnToLobby.textFormat.color	= Fonts.getInstance().colorWhite;
			_btnToLobby.addEventListener(Event.TRIGGERED, onClickToLobby);
			
			_btnOk = new Button(MangoAssetManager.I.getTexture("ok_btn"));
			addChild(_btnOk);
			_btnOk.width	= 50;
			_btnOk.height	= 30;
			_btnOk.x = _Width-200;//780;
			_btnOk.y = _Height-90;//720;
			_btnOk.addEventListener(Event.TRIGGERED, onClickClose);
			
			// close timer label
			_timerLabel = createLabel();
			_timerLabel.text = "Next round in 10 seconds.";
			addChild(_timerLabel);
			_timerLabel.x = 420;
			_timerLabel.y = _Height-70;//670;
		}
		
		
		private function createHandCards(handCards:HandCardsImpl, joker:CardImpl):Sprite
		{
			var cardContainer:Sprite = new Sprite();
			if (!handCards)
				return cardContainer;
			
			var posX:int = 0;
			for (var i:int = 0; i < handCards.groupcards.length; i++)
			{
				var group:GroupCardsImpl = handCards.groupcards[i];
				for (var j:int = 0; j < group.card.length; j++)
				{
					var card:CardView = new CardView();
					if(joker)
						card.initCard(group.card[j], group.card[j].rank == joker.rank, true);
					else
						card.initCard(group.card[j], false, true);
					
					card.toggleDropShadow(false);
					cardContainer.addChild(card);
					card.x = posX;
					posX += card.width/3;
				}
				posX += card.width-10;
			}
			return cardContainer;
		}
		
		private function onClickClose(event:Event):void
		{
			ProxySignals.getInstance().toggleChatWindowSignal.dispatch(false, _table.gameView.room.id);
			PopUpManager.removePopUp(this);
		}
		
		private function onClickToLobby(event:Event):void
		{
			PopUpManager.removePopUp(this, true);
			SFSInterface.getInstance().closeRoom(_table.gameView.room.id, true);
		}
		
		private function onClickManualSplit(event:Event):void
		{
			_btnManualSplit.visible = false;
			initManualSplit();
		}
		
		public function getScrollListData():ScrollContainer
		{
			return _scrollList;
		}
		
		public function refresh(settlement:MatchSettlementImpl, gameImpl:IGame, gameView:GameView, joker:CardImpl, myId:int):void
		{
			_scrollList.removeChildren(0, -1, true);
			if(_joker && this.contains(_joker))
				_joker.removeFromParent(true);
			
			if (!settlement)
				return;
			
			settlement.playersSettlement.sort(sortByScore); // sort list by current score
			
			// always put me on top 
			if (myId != -1)
			{
				for (var i:int = 0; i < settlement.playersSettlement.length; i++)
				{
					var playerSettlement:PlayerSettlementImpl = settlement.playersSettlement[i];
					if (playerSettlement.playerId == myId)
					{
						settlement.playersSettlement.splice(i, 1);
						settlement.playersSettlement.unshift(playerSettlement);
						break;
					}
				}
			}
			
			// populate values
			for (i = 0; i < settlement.playersSettlement.length; i++)
			{
				playerSettlement = settlement.playersSettlement[i];
				
				// update wallet of seated players
				gameView.updatewalletSignal.dispatch(playerSettlement.playerId, (_table.gameImpl is BestOfNGameImpl) ? playerSettlement.currentScore: playerSettlement.balance);
				
				// create rows in score card
				var row:Sprite = createRowForPlayer(playerSettlement, gameImpl, joker, settlement.winnerId);
				_scrollList.addChild(row);
				
				// HACK: since we know that the first one is the winner, show some SFX
				if (i == 0)
				{
					var cmf:ColorMatrixFilter = new ColorMatrixFilter();
					//cmf.adjustSaturation(1);
					//row.filter = cmf;
				}
			}
			
			var winner:PlayerImpl;
			if (settlement.isWinner && settlement.winnerId > 0)
			{
				_isLast = true;
				winner = GameUtil.getPlayerById(gameImpl, settlement.winnerId);
				if (winner)
				{
					if(gameImpl is SyndicateGameImpl)
						SFSInterface.getInstance().flushPlayerNamesOnGameEnd();
					
					showWinnerPopup(winner.name + " has won the game!", true);
				}
			}
			else if (settlement.bnWinners && settlement.bnWinners.length > 0)
			{
				var winnerStrPairs:Array = settlement.bnWinners.split(",");
				var keyValuePair:Array = null;
				if (winnerStrPairs.length == 1)
				{
					keyValuePair = String(winnerStrPairs[0]).split("=");
					winner = GameUtil.getPlayerById(gameImpl, int(keyValuePair[0]));
					if (winner)
						showWinnerPopup(winner.name + " has won the game!", true);
				}
				else if (winnerStrPairs.length > 1)
				{
					var message:String = "Match over, following is the distribution:";
					for (i = 0; i < winnerStrPairs.length; i++)
					{
						keyValuePair = String(winnerStrPairs[i]).split("=");
						winner = GameUtil.getPlayerById(gameImpl, int(keyValuePair[0]));
						var amount:int = int(keyValuePair[1]) / 100;
						message += "\n" + (winner ? winner.name : "null") + " - " + amount.toFixed(2);
					}
					showWinnerPopup(message, false);
				}
			}
			
			function showWinnerPopup(message:String, showInStatus:Boolean):void
			{
				_timerLabel.text = showInStatus ? message : "";
				PopUpManager.root = gameView;
				PopUpManager.addPopUp(new ConfirmationPopup("WINNER", message, onOk, null, 9, onOk));
				
				function onOk():void
				{
					onClickToLobby(null);
					// nothing to do
				}
			}
			
			// put current joker
			if(joker)
			{
				_joker = Ace2JakCard.manufacture(joker.suit, joker.rank, true, true);
				/*_joker.scaleX = 0.7;
				_joker.scaleY = 0.7;*/
				addChild(_joker);
				_joker.x = _joker.width;
				_joker.y = (_Height) -_joker.height*2;
			}
		}
		
		public function closeAfterSeconds(seconds:int):void
		{
			if (!_isLast)
				_timerLabel.text = "Next round in " + seconds + " seconds.";
			
			// attach timer for auto closure
			_closeTimer = new Timer(1000, seconds);
			_closeTimer.addEventListener(TimerEvent.TIMER, onCloseTimerTick);
			_closeTimer.start();
		}
		
		private function onCloseTimerTick(event:TimerEvent):void
		{
			// timer remaining
			var remaining:int = _closeTimer.repeatCount - _closeTimer.currentCount;
			_timerLabel.text = "Next round in " + remaining + " seconds.";
			
			if (remaining == 0)
			{
				_closeTimer.stop();
				_closeTimer.removeEventListener(TimerEvent.TIMER, onCloseTimerTick);
				_btnToLobby.enabled = true;

				if (PopUpManager.isPopUp(this))
					PopUpManager.removePopUp(this);
				
				if((_table.gameImpl is BestOfNGameImpl) && _table.playersCount==1) 
					tableCleanUp();
			}
			
			if (remaining <=5 && remaining >=2 && _btnToLobby.visible)
			{
				if(!_table.isSpectator)
					_btnToLobby.enabled = false;
				//ProxySignals.getInstance().leaveTableDisableSignal.dispatch();
			}
		}
		
		private function tableCleanUp():void
		{
			_table.dispose();
			_table.cleanup();
			SFSInterface.getInstance().closeRoom(_table.gameView.room.id, true);
		}
		
		public function setForPoint(forLastHand:Boolean, betAmount:int):void
		{
			_btnToLobby.visible = !forLastHand;
			_btnOk.visible = forLastHand;
			_btnClose.visible = forLastHand;
			_timerLabel.visible = !forLastHand;
			_btnManualSplit.visible = false;
			
			_lblHeader.text = forLastHand ? "Last Hand - "+ _table.lastGameId: "Game Result - "  + _table.currentGameId;
			_lblScoreOrCount.text = "Count";
			_lblWinLoseOrTotal.text = "Win/Lose";
			_lblBetAmount.text = "Bet: " + Number(betAmount / 100).toFixed(2).toString();
			_lblBetAmount.visible = true;
			_forPoint = true;
			/*_lblWinLoseOrTotal.x = _Width-155;//800
			_lblScoreOrCount.x = _lblWinLoseOrTotal.x - (_lblScoreOrCount.width+10)*///_Width-250;
				
			_lblScoreOrCount.x = _Width - (_headerBg.width/3.5 - _lblScoreOrCount.width/2);
			_lblWinLoseOrTotal.x = _lblScoreOrCount.x + (_lblScoreOrCount.width + _lblWinLoseOrTotal.width/2);
			if(_Width < 900)
			{
				_lblScoreOrCount.x -= 10;
				_lblWinLoseOrTotal.x -= _lblWinLoseOrTotal.width/2;
			}
		}
		
		public function setForPool(forLastHand:Boolean):void
		{
			_btnToLobby.visible = false;
			_btnOk.visible = forLastHand;
			_btnClose.visible = forLastHand;
			_timerLabel.visible = !forLastHand;
			_btnManualSplit.visible = false;
			_lblHeader.text = "Last Hand -" +_table.lastGameId ;
			
			_lblHeader.text = forLastHand ? "Last Hand - "+ _table.lastGameId: "Game Result - "+ _table.currentGameId;
			_lblScoreOrCount.text = "Game Score";
			_lblWinLoseOrTotal.text = "Total Score";
			_lblBetAmount.text = (0).toString();
			_lblBetAmount.visible = false;
			_forPoint = false;
			_lblScoreOrCount.x = _Width - _headerBg.width/4;
			_lblWinLoseOrTotal.x = _lblScoreOrCount.x + (_lblScoreOrCount.width + _lblWinLoseOrTotal.width/2);
			if(_Width < 900)
			{
				_lblScoreOrCount.x -= 10;
				_lblWinLoseOrTotal.x -= _lblWinLoseOrTotal.width/2;
			}
		}
		
		public function updateCloseTime(time:int):void
		{
			if (!_closeTimer)
				return;
			
			_closeTimer.repeatCount = time  + _closeTimer.currentCount + 1;
		}
		
		public function enableManualSplit(splitAmounts:Array):void
		{
			_splitAmounts = splitAmounts;
			_btnManualSplit.visible = _splitAmounts != null;
		}
		
		private function initManualSplit():void
		{
			// show the popup to initiate split
			// prepare the string first
			var message:String = "Do you want to split the prize money accordingly:";
			for each (var item:* in _splitAmounts)
			{
				var playerId:int = item.playerid;
				var splitValue:Number = item.splitvalue / 100;
				var playerName:String = "null";
				
				var seat:SeatView = _table.getSeatByPlayerId(playerId);
				if (seat && seat.seatImpl && seat.seatImpl.player)
					playerName = seat.seatImpl.player.name;
				
				message += "\n" + playerName + "- " + splitValue.toFixed(2);
			}
			
			var remaining:int = _closeTimer.repeatCount - _closeTimer.currentCount - 1;
			//trace ("remaining time ==> " + remaining);
			// do not show the popup if remaining time is less than 1 second
			if (remaining < 1)
				return;
			
			PopUpManager.root = _table.gameView;
			PopUpManager.addPopUp(new ConfirmationPopup("SPLIT", message, onOk, onCancel, remaining, onCancel));
			
			function onOk():void
			{
				SFSInterface.getInstance().manualSplitConfirmation(true, _table.gameView.room);
			}
			
			function onCancel():void
			{
				_btnManualSplit.visible = _splitAmounts != null;
			}
		}
		
		public function setSplitAcceptedForPlayer(playerId:int, value:Boolean):void
		{
			var row:DisplayObjectContainer = _scrollList.getChildByName(playerId.toString()) as DisplayObjectContainer;
			var overlay:DisplayObject = row.getChildByName(playerId.toString()) as DisplayObject;
			overlay.visible = true;
			overlay.x		= 18;
		}
		
		public function removeAllHighlights():void
		{
			for (var i:int = 0; i < _scrollList.numChildren; i++)
			{
				var row:Sprite = _scrollList.getChildAt(i) as Sprite;
				if (row && row.name && row.name != "")
				{
					for (var j:int = 0; j < _scrollList.numChildren; j++)
					{
						var overlay:Image = row.getChildAt(j) as Image;
						if (overlay && overlay.name && overlay.name != "")
							overlay.visible = false;
					}
				}
			}
		}
		
		public function set header(value:String):void { _lblHeader.text = value; }
		
		public static function createLabel():TextField
		{
			var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 14;
			
			var textFomat:starling.text.TextFormat	= new starling.text.TextFormat(Fonts.getInstance().fontRegular, fontSize, Color.WHITE, "left");
			var label:TextField = new TextField(1, 1, "", textFomat);
			label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			label.alignPivot("center", "center");
			label.text = "";
			return label;
		}
		
		public static function createFeathersLabel():Label
		{
			var label1:Label	= new Label();
			label1.textRendererFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				textRenderer.textFormat = new flash.text.TextFormat( Fonts.getInstance().fontRegular, 12, 0xFFFFFF );
				return textRenderer;
			}
				label1.alignPivot();
				return label1;
		}
		
		public static function getProxyData():MatchSettlementImpl
		{
			var matchSettlement:MatchSettlementImpl = new MatchSettlementImpl();
			for (var i:int = 0; i < 6; i++)
			{
				var playerSettlement:PlayerSettlementImpl = new PlayerSettlementImpl();
				playerSettlement.playerId = i;
				playerSettlement.seatId = i;
				playerSettlement.handCards = InGameHud.getHandCards();
				playerSettlement.currentScore = Math.random() * 80;
				playerSettlement.totalScore = Math.random() * 201;
				matchSettlement.playersSettlement.push(playerSettlement);
			}
			if (true)
			{
				matchSettlement.isWinner = true;
				matchSettlement.winnerId = 0;
			}
			return matchSettlement;
		}
		
		private static function sortByScore(item1:PlayerSettlementImpl, item2:PlayerSettlementImpl):Number
		{
			if (item1.currentScore < item2.currentScore) return -1;
			if (item1.currentScore > item2.currentScore) return 1;
			return 0;
		}
	}
}