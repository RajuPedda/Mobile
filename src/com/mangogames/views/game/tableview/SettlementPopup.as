package com.mangogames.views.game.tableview
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.rummy.model.impl.BestOfNGameImpl;
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.DealPlayerImpl;
	import com.mangogames.rummy.model.impl.GroupCardsImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.PointsGameImpl;
	import com.mangogames.rummy.model.util.GameUtil;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.views.AbstractBaseView;
	import com.mangogames.views.common.Hud;
	import com.mangogames.views.popup.ConfirmationPopup;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.core.PopUpManager;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import utils.Ace2JakCard;
	import utils.Fonts;
	import utils.PlayerState;
	import utils.ScaleUtils;

	public class SettlementPopup extends Sprite
	{
		private var _table:TableView;
		private var _btnManualSplit:Button;
		private var _lblHeader:TextField;
		private var _lblBetAmount:TextField;
		private var _lblScoreOrCount:TextField;
		private var _lblWinLoseOrTotal:TextField;
		private var _forPoint:Boolean;
		private var _isLast:Boolean;
		private var _splitAmounts:Array;
		private var _btnClose:Button;
		private var _btnToLobby:Button;
		private var _closeTimer:Timer;
		private var _timerLabel:TextField;
		private var _scrollList:ScrollContainer;
		private var _mcBusyIndicator:MovieClip;
		private var _joker:Ace2JakCard;
		private var _Height:int;
		private var _Width:int;
		private var _headerBg:Image;
		private var _popupBg:Image;
		
		public function SettlementPopup(table:TableView)
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
		
		override public function dispose():void
		{
			if(_closeTimer) _closeTimer.removeEventListener(TimerEvent.TIMER, onCloseTimerTick);
			_scrollList.removeChildren(0, -1, true);
			_scrollList.removeFromParent(true);
			_btnClose.removeEventListener(Event.TRIGGERED, onClickClose);
			_btnToLobby.removeEventListener(Event.TRIGGERED, onClickToLobby);
			//removeChildren(0, -1, true);
		}
		
		private var _resultLabel:TextField;
		private var _nameLabel:TextField;
		private var _rowBg:Image;
		
		private function initHeader():void
		{
			_lblHeader = createLabel();
			_lblHeader.text = "Game Result - "+_table.currentGameId ;
			_lblHeader.format.size = 12;
			_lblHeader.format.color	= Color.WHITE;
			addChild(_lblHeader);
			_lblHeader.x = 70;
			_lblHeader.y = 10;
			
			_lblBetAmount = createLabel();
			var betAmount:int	= _table.gameView.room.getVariable("Bet").getIntValue();	
			_lblBetAmount.text = "Bet: " + Number(betAmount / 100).toFixed(2).toString();
			_lblBetAmount.format.size = 12; 
			_lblBetAmount.format.color	= Color.WHITE;
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
			_btnClose = new Button(MangoAssetManager.I.getTexture("close_x"), "");
			addChild(_btnClose);
			_btnClose.x = _popupBg.width - _btnClose.width - 5;
			_btnClose.y = 10;
			_btnClose.addEventListener(Event.TRIGGERED, onClickClose);
			_btnClose.visible = false;
		}
		
		public function showScoreValues(me:PlayerImpl, currentPlayers:SFSArray, handCards:HandCardsImpl, score:int, winnerPlayerId:int=0, totScore:int=0):void
		{
			var len:int	= currentPlayers?currentPlayers.size():0;
			var dealPlayer:DealPlayerImpl;
			var dealPlayersList:Array = [];
			if(currentPlayers)
			{
				for(var i:int=0; i<len; i++)
				{
					dealPlayer	= currentPlayers.getClass(i);
					dealPlayersList.push(dealPlayer);
				}
			}
			var dealPlayersLen:int	= _table.dealImpl.dealplayer.length;
			var player:PlayerImpl;
			var found:Boolean;
			var dealPlayers:Array	= _table.dealImpl.dealplayer;
			
			// I should be displayed top in the list 
			for(i=0; i<dealPlayersLen; i++)
			{
				dealPlayer	= dealPlayers[i];
				if(dealPlayer.dbId == me.id)
				{
					dealPlayers.splice(i, 1);
					dealPlayers.unshift(dealPlayer);
					//break;
				}
				if(dealPlayer.dbId == winnerPlayerId)
					dealPlayer.handcards	= handCards;
			}
			
			var joker:CardImpl	= _table.dealImpl.joker.card;
			for(i=0; i<dealPlayersLen; i++)
			{
				dealPlayer	= dealPlayers[i];
				if(dealPlayer)
				{
					for(var j:int=0; j<dealPlayersList.length; j++)
					{
						if(dealPlayer.dbId == dealPlayersList[j].dbId)
						{
							dealPlayer	= dealPlayersList[j];
						}
					}
					player	= GameUtil.getPlayerById(_table.gameImpl, dealPlayer.dbId);
					var row:Sprite	= createRowForPlayer(dealPlayer, player, joker, winnerPlayerId, totScore);
					_scrollList.addChild(row);
				}
			}
			
			// put current joker
			if(joker && !_joker)
			{
				_joker = Ace2JakCard.manufacture(joker.suit, joker.rank, true, true);
				/*_joker.scaleX = 0.7;
				_joker.scaleY = 0.7;*/
				addChild(_joker);
				_joker.x = 65;
				_joker.y = (_Height) -_joker.height*2;
			}
			
			if(_lblHeader) _lblHeader.text = "Game Result - "+_table.currentGameId ;
			
		}
		
		public function createRowForPlayer(dealPlayer:DealPlayerImpl, player:PlayerImpl, joker:CardImpl, winnerPlayerId:int, totScore:int):Sprite
		{
			var row:Sprite = new Sprite();
			row.name = player?player.id.toString():null;
	
			// row bg
			_rowBg 				= new Image(MangoAssetManager.I.getTexture("scoreBoard_Body_Bg"));
			_rowBg.width		= _Width - _Width/14;
			_rowBg.x			= 0;
			_rowBg.y			= 0;
			row.addChild(_rowBg);
			
			// split-accepted overlay, hidden by default
		/*	var greenOverlay:Quad	= new Quad(833, 67, 0x529e1b);
			greenOverlay.alpha		= 0.3;
			greenOverlay.name 		= player?player.id.toString():"";
			greenOverlay.visible 	= false;*/
			//row.addChild(greenOverlay);
			
			// name
			var label:TextField = createLabel();
			label.text = player && player.name ? player.name : "null";
			row.addChild(label);
			label.x = _nameLabel.x - _nameLabel.width; 
			label.y = _rowBg.y+ (_rowBg.height-label.height)/2+10; 
			
			// result
			var result:TextField = createLabel();
			result.alignPivot("left", "center");
			result.name	= "playerState";
			result.text = (winnerPlayerId == dealPlayer.dbId)?"Winner":PlayerState.toString(dealPlayer.state);
			if(dealPlayer.state == PlayerState.DEAL_PLAYER_GONE)
				result.text = "Lose";
			row.addChild(result);
			result.x = _resultLabel.x - _resultLabel.width+10; 
			result.y = label.y;
			
			
			var winner_star:Image	= new Image(MangoAssetManager.I.getTexture("winner_star"));
			row.addChild(winner_star);
			winner_star.name		= "winnerStar";
			winner_star.x			= label.x+5;
			winner_star.y			= label.y-18;
			winner_star.visible		= false;
			
			var playerCards:TextField = createLabel();
			playerCards.name	= "playercards";
			playerCards.text = "Waiting for player cards ..."
			row.addChild(playerCards);
			playerCards.x = (_rowBg.width-playerCards.width)/2;; 
			playerCards.y = 5;
			playerCards.visible	= false;
			
			var needToShowLoader:Boolean	= true;
			
			// cards
			if (dealPlayer.state != PlayerState.DROPPED &&
				dealPlayer.state != PlayerState.FIRST_DROP &&
				dealPlayer.state != PlayerState.MIDDLE_DROP && (dealPlayer.state == PlayerState.DONE_WITH_SHOW || dealPlayer.state == PlayerState.INVALID_SHOW))
			{
				needToShowLoader	= false;
				var cardContainer:Sprite = createHandCards(dealPlayer.handcards, joker);
				row.addChild(cardContainer);
				cardContainer.x = (_rowBg.width-cardContainer.width)/2;
				cardContainer.y = 2;
			}
			if(winnerPlayerId == dealPlayer.dbId)
			{
				needToShowLoader	= false;
				var cardContainerW:Sprite = createHandCards(dealPlayer.handcards, joker);
				row.addChild(cardContainerW);
				cardContainerW.x = (_rowBg.width-cardContainerW.width)/2;
				cardContainerW.y = 2;
			}
			
			// count/game score
			var score:TextField = createLabel();
			score.name	= "score";
			var scoreValue:int	= dealPlayer.score.score;
			if(scoreValue == -1)
				scoreValue	= 0;
				
			score.text = scoreValue.toString();
			row.addChild(score);
			
			score.x = _lblScoreOrCount.x; 
			score.y = _rowBg.y+ (_rowBg.height-score.height)/2;
			
			// win-lose/total score
			label = createLabel();
			
			label.text = (_table.gameImpl is PointsGameImpl)
				? "-" + Number(dealPlayer.wonorloss / 100).toFixed(2).toString()
				: dealPlayer.totalScore.toString();
			if(winnerPlayerId == dealPlayer.dbId)
				label.text		= totScore.toString();
			label.name	= "wonorloss";
			row.addChild(label);
			
			label.x =  _lblWinLoseOrTotal.x; 
			label.y = _rowBg.y+ (_rowBg.height-label.height)/2;
			
			var playerDropped:Boolean = false;
			
			if (dealPlayer.state == PlayerState.DROPPED ||
				dealPlayer.state == PlayerState.FIRST_DROP ||
				dealPlayer.state == PlayerState.MIDDLE_DROP ||
				dealPlayer.state == PlayerState.GONE ||
				dealPlayer.state == PlayerState.INVALID_SHOW ||
				dealPlayer.state == PlayerState.DEAL_PLAYER_GONE)	
			{
				playerDropped	= true;
			}
			if(needToShowLoader && !playerDropped && dealPlayer)
			{
				score.text				= "-";
				playerCards.visible 	= true;
				label.visible			= false;
				_mcBusyIndicator 		= Hud.getBusyIndicator();
				_mcBusyIndicator.name	= "loader";
				row.addChild(_mcBusyIndicator);
				_mcBusyIndicator.scaleX	= 0.4;
				_mcBusyIndicator.scaleY	= 0.4;
				
				_mcBusyIndicator.x = _Width-210+ (95 - _mcBusyIndicator.width) / 2;
				_mcBusyIndicator.y = _rowBg.y+ (_rowBg.height-_mcBusyIndicator.height)/2;
			}
			
			return row;
		}
		
		public function refresh(playerId:int, scoreVal:int, handCards:HandCardsImpl, wonOrLoss:int, winnerAmount:int=0, totalScore:int=0):void
		{
			var row:DisplayObjectContainer 		= _scrollList.getChildByName(playerId.toString()) as DisplayObjectContainer;
			var scoreLabel:DisplayObject 		= row.getChildByName("score") as DisplayObject;
			var playerStateLabel:DisplayObject 	= row.getChildByName("playerState") as DisplayObject;
			var wonorLossLabel:DisplayObject 	= row.getChildByName("wonorloss") as DisplayObject;
			var loader:DisplayObject 			= row.getChildByName("loader") as DisplayObject;
			var playerCards:DisplayObject		= row.getChildByName("playercards") as DisplayObject;
			var winner_star:DisplayObject		= row.getChildByName("winnerStar") as DisplayObject;
			
			if(winnerAmount >0)
			{
				if(_table.gameImpl is PointsGameImpl)
				{
					wonorLossLabel.visible		= true;
					if(playerCards)	playerCards.visible			= false;
					if(loader && row.contains(loader))
						loader.removeFromParent(false);
					(wonorLossLabel as TextField).text		= "+" +(winnerAmount / 100).toFixed(2).toString();
				}
				winner_star.visible						= true;
				(playerStateLabel as TextField).text	= "Winner";
			}
			else
			{
				if(playerCards)	playerCards.visible			= false;
				
				if(totalScore >0)
				{
					(wonorLossLabel as TextField).text		= totalScore.toString();
				}
				var cardContainer:Sprite = createHandCards(handCards, _table.dealImpl.joker.card);
				row.addChild(cardContainer);
				cardContainer.x = (_rowBg.width-cardContainer.width)/2; //220;
				
				cardContainer.y = 2;
				
				if(scoreVal <0)
					scoreVal = 0;
				
				(scoreLabel as TextField).text			= scoreVal.toString();
				if(scoreVal >0)
					(playerStateLabel as TextField).text	= "Lose";
				
				if(_table.gameImpl is PointsGameImpl)
				{
					(wonorLossLabel as TextField).text		= "-"+(wonOrLoss / 100).toFixed(2).toString();
				}
				
				wonorLossLabel.visible		= true;
				if(loader && row.contains(loader))
					loader.removeFromParent(false);
			}
			var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 14;
			(playerStateLabel as TextField).format.size	= fontSize;
			
			playerStateLabel.x 	=_resultLabel.x - _resultLabel.width+10; 
			playerStateLabel.y 	= _rowBg.y+ (_rowBg.height-playerStateLabel.height)/2+10; 
			
			scoreLabel.x = _lblScoreOrCount.x; 
			scoreLabel.y = _rowBg.y+ (_rowBg.height-scoreLabel.height)/2;
			
			wonorLossLabel.x 	= _lblWinLoseOrTotal.x; 
			
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
				posX += card?card.width-10:0;
			}
			return cardContainer;
		}
		
		private function initToLobbyButton():void
		{
			var Height:int	= _Height;
			var Width:int	= _Width;
			
			_btnToLobby = new Button(MangoAssetManager.I.getTexture("leavetable_btn_02"), "");
			addChild(_btnToLobby);
			_btnToLobby.x = _Width-200;//810;
			_btnToLobby.y = _Height-92//665;
			_btnToLobby.textFormat.color	= Fonts.getInstance().colorWhite;
			_btnToLobby.addEventListener(Event.TRIGGERED, onClickToLobby);
				
			// close timer label
			_timerLabel = createLabel();
			_timerLabel.text = "";
			addChild(_timerLabel);
			_timerLabel.x = (_Width - _timerLabel.width)/2;
			_timerLabel.y = _Height-57;
		}
		
		private function onClickToLobby(event:Event):void
		{
			PopUpManager.removePopUp(this, true);
			SFSInterface.getInstance().closeRoom(_table.gameView.room.id, true);
		}
		
		private function initSettlement():void
		{
			_scrollList = new ScrollContainer();
			_scrollList.verticalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_scrollList.elasticity = 0;
			_scrollList.throwElasticity =0;
			_scrollList.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_FIXED;
			var layout:VerticalLayout = new VerticalLayout();
			layout.gap = 1;
			
			
			_scrollList.layout = layout;
			_scrollList.x = _Width/30;
			_scrollList.y = _Height/6.35;
			_scrollList.width = _Width-60;
			_scrollList.height = _Height -90;
			
			addChild(_scrollList);
			
			//refreshScore();
		}
		
		
		public static function createLabel():TextField
		{
			var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 14;
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, fontSize, Color.WHITE, "left");
			var label:TextField = new TextField(1, 1, "", tf);
			label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			label.alignPivot("left", "center");
			label.text = "";
			return label;
		}
		
		private function onClickClose(event:Event):void
		{
			PopUpManager.removePopUp(this);
		}
		
		public function closeAfterSeconds(seconds:int):void
		{
			if (!_isLast)
				_timerLabel.text = "Next round in " + seconds + " seconds.";
			
			_timerLabel.x = (_Width - _timerLabel.width)/2;
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
		
		public function setSplitAcceptedForPlayer(playerId:int, value:Boolean):void
		{
			var row:DisplayObjectContainer = _scrollList.getChildByName(playerId.toString()) as DisplayObjectContainer;
			var overlay:DisplayObject = row.getChildByName(playerId.toString()) as DisplayObject;
			overlay.visible = true;
		}
		
		private function onClickManualSplit(event:Event):void
		{
			_btnManualSplit.visible = false;
			initManualSplit();
		}
		
		public function updateCloseTime(time:int):void
		{
			if (!_closeTimer)
				return;
			
			_closeTimer.repeatCount = time  + _closeTimer.currentCount + 1;
		}
		
		
		public function setForPoint(forLastHand:Boolean, betAmount:int):void
		{
			_btnToLobby.visible = !forLastHand;
			_btnClose.visible = forLastHand;
			_timerLabel.visible = !forLastHand;
			_btnManualSplit.visible = false;
			
			_lblHeader.text = forLastHand ? "Last Hand -" : "Game Result -";
			_lblScoreOrCount.text = "Count";
			_lblWinLoseOrTotal.text = "Win/Lose";
			_lblBetAmount.text = "Bet: " + Number(betAmount / 100).toFixed(2).toString();
			_lblBetAmount.visible = true;
			_forPoint = true;
			_lblScoreOrCount.x = _Width - (_headerBg.width/4 - _lblScoreOrCount.width/2);
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
			_btnClose.visible = forLastHand;
			_timerLabel.visible = !forLastHand;
			_btnManualSplit.visible = false;
			
			_lblHeader.text = forLastHand ? "Last Hand -" : "Game Result -";
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
		
	}
}