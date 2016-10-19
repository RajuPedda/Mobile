package com.mangogames.views.game.tableview
{
	import com.junkbyte.console.Cc;
	import com.mangogames.audio.SoundDirector;
	import com.mangogames.events.HandCardIndicatorTouchedEvent;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.rummy.model.impl.BestOfNGameImpl;
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.MatchImpl;
	import com.mangogames.rummy.model.impl.MatchSettlementImpl;
	import com.mangogames.rummy.model.impl.OpenDeckImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.PointsGameImpl;
	import com.mangogames.rummy.model.impl.SeatImpl;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.game.GameView;
	import com.mangogames.views.popup.ConfirmationPopup;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	
	import feathers.core.PopUpManager;
	
	import logger.Logger;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.GlowFilter;
	import starling.utils.Color;
	
	import utils.Ace2JakCard;
	import utils.ScaleUtils;
	
	public class RummyTableView extends TableView
	{
		public static const CLOSED_DECK:int = 0;
		public static const OPEN_DECK:int = 1;
		
		private var _jokerArea:Sprite;
		private var _closedDeckArea:ClosedDeckView;
		private var _openDeckArea:OpenDeckView;
		private var _declareDeck:DeclareView;
		private var _meldArea:MeldAreaView;
		private var _newCardReceived:Boolean;
		private var _aboutToDeclare:Boolean;
		private var _lastTurnSeatId:int;
		private var _seatingPos:int=0;
		private var _closedDeckText:Image;
		private var _openDeckText:Image;
				
		public function RummyTableView(gameView:GameView)
		{
			super(gameView);
			
			var gameScreen:XML = MangoAssetManager.I.gameElements;
			
			// position different area on table
			_jokerArea = new Sprite();
			addChild(_jokerArea);
			_jokerArea.x = WIDTH/2- _jokerArea.width*2;	
			_jokerArea.y = HEIGHT/2;
			
			_closedDeckArea = new ClosedDeckView();
			addChild(_closedDeckArea);
			
			_openDeckArea = new OpenDeckView(this);
			addChild(_openDeckArea);
			_openDeckArea.x = WIDTH/2+ _openDeckArea.width;
			_openDeckArea.y = (HEIGHT-_openDeckArea.height)/2; 
			
			_declareDeck = new DeclareView();
			addChild(_declareDeck);
			_declareDeck.x = WIDTH/2+ _declareDeck.width*2;
			_declareDeck.y = (HEIGHT-_declareDeck.height)/2; 
			
			// indicator area for sorted group highlights
			var indicatorArea:Sprite = new Sprite();
			addChild(indicatorArea);
			_meldArea = new MeldAreaView(this, indicatorArea);
			addChild(_meldArea);
			
			_discardedCardView = new DiscardedCardsView(WIDTH, HEIGHT);
			addChild(_discardedCardView);
			_discardedCardView.x = WIDTH/2 - 10; ///495;
			_discardedCardView.y = HEIGHT/40;
			
			_discardedCardView.visible = false;
			
			_gameView.discardedcardSignal.add(onCardDiscarded);
			_gameView.newcardreceivedSignal.add(onNewCardReceived);
			_gameView.playerpickedcardSignal.add(onPlayerPickedCard);
			_gameView.pickerrorSignal.add(onCardPickError);
			
			// add hud
			_inGameHud = new InGameHud(this);
			addChild(_inGameHud);
			
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			//initDebuggerConsole();
			
			_closedDeckText	= new Image(MangoAssetManager.I.getTexture("closed_deck_text"));
			_closedDeckText.x			= _closedDeckArea.x+10;
			_closedDeckText.y			= _closedDeckArea.y + 145;
			_closedDeckText.visible		= false;
			//addChild(_closedDeckText);
			
			_openDeckText	= new Image(MangoAssetManager.I.getTexture("open_deck_text"));
			_openDeckText.x			= _openDeckArea.x;
			_openDeckText.y			= _openDeckArea.y + 140;
			_openDeckText.visible	= false;
			//addChild(_openDeckText);
		}
		
		
		private function initDebuggerConsole():void
		{
			super.initDebugger();
			
			Cc.store("addNewCard", function (seatId:int, pickedFrom:int, rank:int, suit:int):void 
			{
				var newCard:CardImpl	= new CardImpl();
				newCard.rank			= rank;
				newCard.suit			= suit;
				onNewCardReceived(seatId, pickedFrom, newCard);
			});
		}
		
		override protected function showDiscardsPopup():void
		{
			super.showDiscardsPopup();
			var initialPosition:Number = _discardedCardView.x + _discardedCardView.width;
			_discardedCardView.visible = true;
			_discardedCardView.scaleX = 0.1;
			_discardedCardView.scaleY = 0.1;
			
			var tween:Tween = new Tween(_discardedCardView, 0.3, Transitions.EASE_IN_OUT);
			tween.scaleTo(1);
			tween.onUpdate = tween_update;
			tween.onUpdateArgs = [initialPosition];
			Starling.juggler.add(tween);
		}
		
		private function tween_update(initialPosition:Number):void
		{
			_discardedCardView.x = initialPosition - _discardedCardView.width;
		}
		
		override public function dispose():void
		{
			_gameView.discardedcardSignal.removeAll();
			_gameView.newcardreceivedSignal.removeAll();
			_gameView.playerpickedcardSignal.removeAll();
			_gameView.pickerrorSignal.removeAll();
			
			_jokerArea.removeFromParent(true);
			_closedDeckArea.removeFromParent(true);
			_openDeckArea.removeFromParent(true);
			_meldArea.removeFromParent(true);
			
			super.dispose();
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_closedDeckArea);
			if (touch)
			{
				if (touch.phase == TouchPhase.ENDED)
					SFSInterface.getInstance().cardPicked(0, _gameView.room); // 0 - closed deck
				
				return;
			}
			
			touch = event.getTouch(_openDeckArea);
			if (touch)
			{
				if (touch.phase == TouchPhase.ENDED)
					SFSInterface.getInstance().cardPicked(1, _gameView.room); // 1 - open deck
				
				return;
			}
			
			touch = event.getTouch(_meldArea);
			if (touch)
			{
				_meldArea.onTouch(event);
				return;
			}
		}
		
		private function onCardDiscarded(seatId:int, wasTurnMissed:Boolean, lastCard:CardImpl):void
		{
			Logger.log("discarded card, rank: " + lastCard.rank + ", suit: " + lastCard.suit + ", missed turn: " + wasTurnMissed);
			
			_newCardReceived = false;
			updateOpenDeckWith(lastCard);
			
			var seatView:SeatView = getSeatBySeatId(seatId);
			var playerName:String = (seatView && seatView.seatImpl && seatView.seatImpl.player) ? seatView.seatImpl.player.name : null;
			
			_discardedCardView.addDiscardedCard(lastCard, playerName, (_dealImpl && _dealImpl.joker)?_dealImpl.joker.card.rank : -1);
			
			_lastTurnSeatId = seatId;
			
			// if the turn was missed and it was for the current player then remove his drawn card
			if (wasTurnMissed && seatId == _mySeatId)
				_meldArea.discardNewCard();
			
			if (seatId == _mySeatId)
			{
				SoundDirector.getInstance().playSound(SoundDirector.PICK_DISCARD);
				//return;
			}
			
			// animate
			if (seatView) // FIXME: this seat should never be null
			{
				var posX:int = seatView.handCardPosX;
				var posY:int = seatView.handCardPosY;
				
				if (seatId == _mySeatId && !isSpectator)
				{
					posX = meldArea.xPos_disacardedcard;
					posY = meldArea.yPos_discardedCard;
				}
				
				throwCard(posX, posY, _openDeckArea.x, _openDeckArea.y, 0.25, null);
				
				var message:String = (seatView.seatImpl.player ? seatView.seatImpl.player.name : "null")  + " has discarded " + Ace2JakCard.getCardName(lastCard.suit, lastCard.rank) + ".";
				ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
				ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
			}
		}
		
		// this is for me
		public function onNewCardReceived(seatId:int, pickedFrom:int, newCard:CardImpl):void
		{
			Logger.log("received new card, rank: " + newCard.rank + ", suit: " + newCard.suit);
			
			var message:String = "You received " + Ace2JakCard.getCardName(newCard.suit, newCard.rank) + ".";
			ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
			//ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message, _gameView.room.id);
			
			_newCardReceived = true;
			
			var cardView:CardView = _meldArea.addNewCard(newCard);
			
			// now keep the new card on meld area
			var posX:int = _meldArea.width;//predictLastCardPosition();
			var posY:int = HEIGHT-(cardView.height+5);//MangoAssetManager.I.gameElements.theme.meldArea.@y;
			
			var delay:Number = 0.4;
			
			// cheap hack
			cardView.visible = false;
			Starling.juggler.delayCall(function ():void { cardView.visible = true; }, delay);
			
			// animate
			switch (pickedFrom)
			{
				case CLOSED_DECK:
					throwCard(_closedDeckArea.x, _closedDeckArea.y, posX, posY, delay, cardView.card.cardName);
					break;
				
				case OPEN_DECK:
					throwCard(_openDeckArea.x, _openDeckArea.y, posX, posY, delay, cardView.card.cardName);
					break;
			}
			
			// stop glow if this was my turn
			if (seatId == _mySeatId)
			{
				_closedDeckArea.stopGlow();
				_openDeckArea.stopGlow();
			}
		}
		
		private function onPlayerPickedCard(playerId:int, pickedFrom:int, pickedCard:CardImpl):void
		{
			Logger.log("picked card from: " + (pickedFrom == OPEN_DECK ? "open deck, " : "closed deck"));
			
			// this will show the last discarded card
			if ((pickedFrom == OPEN_DECK && _dealImpl))
			{
				var card:CardImpl = _dealImpl.opendeck.card.pop();
				_openDeckArea.updateDeck();
				var lastSeatView:SeatView = getSeatBySeatId(_lastTurnSeatId);
				var playerName:String = (lastSeatView && lastSeatView.seatImpl && lastSeatView.seatImpl.player) ? lastSeatView.seatImpl.player.name : null;
				_discardedCardView.removeDiscardedCard(card, playerName);
			}
			
			// simulate card pick
			var seatView:SeatView = getSeatByPlayerId(playerId);
			if (!seatView)
				return; // FIXME: this seat should never be null
			
			var message:String = (seatView.seatImpl.player ? seatView.seatImpl.player.name : "null")  + " has drawn a " + (pickedFrom == OPEN_DECK ? "open" : "closed") + " deck card.";
			ProxySignals.getInstance().gameLogUpdatedSignal.dispatch(message, _gameView.room.id);
			
			var message1:String = (seatView.seatImpl.player ? seatView.seatImpl.player.name : "null")  + " has drawn a " + (pickedFrom == OPEN_DECK ? "open" : "closed")
				+" deck card." + Ace2JakCard.getCardName(pickedCard.suit, pickedCard.rank) + "."
			
			ProxySignals.getInstance().gameLogTrackDataSignal.dispatch(message1, _gameView.room.id);
			
			// if it is me, then don't do anything here, it is handled in newCardReceived method 
			if (seatView.seatImpl.seatId == _mySeatId)
			{
				SoundDirector.getInstance().playSound(SoundDirector.PICK_DISCARD);
				if(!isSpectator)
					return;
			}
			
			var delay:Number = 0.4;
			switch (pickedFrom)
			{
				case CLOSED_DECK:
					throwCard(_closedDeckArea.x, _closedDeckArea.y, seatView.handCardPosX, seatView.handCardPosY, delay, null);
					break;
				
				case OPEN_DECK:
					throwCard(_openDeckArea.x, _openDeckArea.y, seatView.handCardPosX, seatView.handCardPosY, delay, null);
					break;
			}
		}
		
		private function onCardPickError(messageCode:int):void
		{
			var message:String = "";
			
			switch (messageCode)
			{
				case 0: message = ""; break;
				case 1: message = "Please wait for your turn"; break;
				case 2: message = "You cannot pick a joker form open deck"; break;
			}
			
			if (message.length > 0)
				showDealerMessage(message, 2);
		}
		
		private function updateOpenDeckWith(card:CardImpl):void
		{
			if(_dealImpl)
			{
				var openDeck:OpenDeckImpl = _dealImpl.opendeck;
			//	openDeck.card.unshift(card);
				openDeck.card.push(card);
				_openDeckArea.updateDeck();
			}
		}
		
		private function throwCard(throwFromX:int, throwFromY:int, throwToX:int, throwToY:int, delay:Number, cardName:String):void
		{
			var closedCardImage:Image = new Image(MangoAssetManager.I.getTexture(cardName ||= "Back"));
			addChild(closedCardImage);
			closedCardImage.x = throwFromX;
			closedCardImage.y = throwFromY;
			
			var tween:Tween = new Tween(closedCardImage, delay);
			tween.moveTo(throwToX, throwToY);
			Starling.juggler.add(tween);
			tween.onComplete = function ():void
			{
				Starling.juggler.remove(tween);
				
				if (closedCardImage && closedCardImage.parent)
					closedCardImage.removeFromParent(true);
			};
		}
		
		override public function cleanup():void
		{
			_meldArea.clearMeldArea();
			_meldArea.toggleFoldCards(false);
			if (mySeat)
				mySeat.toggleShowHandCards(false);
			_openDeckArea.clear();
			_openDeckArea.stopHighlight();
			_declareDeck.clear();
			_closedDeckArea.removeChildren(0, -1, true);
			_closedDeckArea.visible = true;
			_jokerArea.removeChildren(0, -1, true);
			_jokerArea.visible = true;
			_newCardReceived = false;
			_aboutToDeclare = false;
			_discardedCardView.reset();
			_lastTurnSeatId = 0;
			super.cleanup();
		}
		
		override protected function onPlayerDropped(seatId:int, playerId:int, penaltyScore:int):void
		{
			super.onPlayerDropped(seatId, playerId, penaltyScore);
			
			if (seatId == _mySeatId)
				_meldArea.fold();
		}
		
		override protected function onTurnOver(seatId:int, timeOut:int, isMyTablePlayer:Boolean=false, openCardSeatId:int=0):void
		{
			super.onTurnOver(seatId, timeOut, isMyTablePlayer, openCardSeatId);
			
			// glow if this is my turn
			if (seatId == _mySeatId)
			{
				_closedDeckArea.startGlow();
				_openDeckArea.startGlow();
			}
			else
			{
				isForceShowBtnEnable	= false;
			}
			
			_inGameHud.removeConfirmShowPopup();
			
			// enable declare button on my turn
			_canDeclare = seatId == _mySeatId;
		}
		
		override protected function myTableJoin(data:Object):void
		{
			super.myTableJoin(data);
			if(data.seatId == _mySeatId && data.pickedCard)
			{
				//_newCardReceived	= true;
				_meldArea.addNewCard(data.pickedCard);
			}
			
			if(data.matchSettlement)
			{
				joker	= data.joker;
				var needToShow:Boolean	= _gameImpl is PointsGameImpl?false:true;
				
				_inGameHud.toggleScorecardButton(needToShow, true);
				if(data.scoreCardTicker > 0)
				{
					_inGameHud.showLastHand(data.scoreCardTicker);
					cleanup();
				}
				
				// minimize chat
				ProxySignals.getInstance().toggleChatWindowSignal.dispatch(true, _gameView.room.id);
				
				if(_gameImpl is BestOfNGameImpl && _playersCount == 1)
				{
					onPlayerLeft(_playerLeftSeatId, 0);
				}
			}
			
		}
		
		override protected function onMatchSettlement(match:MatchImpl, matchSettlement:MatchSettlementImpl, timer:int, GameId:String, isMatchTie:Boolean):void
		{
			super.onMatchSettlement(match, matchSettlement, timer, GameId, isMatchTie);
			
			var needToShow:Boolean	= _gameImpl is PointsGameImpl?false:true;
			
			_inGameHud.toggleScorecardButton(needToShow, true);
			_inGameHud.showLastHand(timer); // CHANGED
			
			if(_gameImpl is BestOfNGameImpl && _playersCount == 1)
			{
				onPlayerLeft(_playerLeftSeatId, 0);
			}
			_inGameHud.disableSubmitBtn();
			
			if(_gameImpl is BestOfNGameImpl && isMatchTie)
			{
				PopUpManager.root = gameView;
				var message:String		= "Your match got tied, next match will be deciding match for you";
				var matchTiePopup:ConfirmationPopup	= new ConfirmationPopup("", message, onOk, null, 5, onOk);
				PopUpManager.addPopUp(matchTiePopup);
				
				function onOk():void
				{
					if(PopUpManager.isPopUp(matchTiePopup))
						PopUpManager.removePopUp(matchTiePopup);
				}
			}
			cleanup();
			
		}
		
		public function prepareToDeclare():void
		{
			if (!_meldArea.selectedCards || _meldArea.selectedCards.length == 0)
				return;
			
			var cardToThrow:CardView = CardView(_meldArea.selectedCards[0]);
			if (!cardToThrow)
				return;
			
			throwCard(cardToThrow.x, cardToThrow.y, _declareDeck.x, _declareDeck.y, 0.3, cardToThrow.card.cardName);
			declareArea.highlight();
			
			// just to simulate that the last card has been dropped on declare area
			_declareDeck.updateDeck(cardToThrow.cardImpl, dealImpl.joker.card.rank);
			_meldArea.prepareForDeclare(cardToThrow);
			_aboutToDeclare = true;
			
			Starling.juggler.delayCall(function ():void
			{
				var discardedCard:CardImpl = declareArea.cardImpl;
				
				SFSInterface.getInstance().initShow(gameView.room, _meldArea.getHandCards(), discardedCard);
			}, 0.3);
		}
		
		override protected function onShowCards(seatId:int, timeout:int, score:int, leftPlayers:SFSArray, handCards:HandCardsImpl=null, totScore:int=0):void
		{
			super.onShowCards(seatId, timeout, score, leftPlayers, handCards, totScore);
			
			if (seatId != _mySeatId)
				_inGameHud.setForSubmit();
		}
		
		override protected function onInvalidShow(playerId:int, discardedCard:CardImpl, wrongPenalty:int):void
		{
			super.onInvalidShow(playerId, discardedCard, wrongPenalty);
			if (discardedCard)
			{
				updateOpenDeckWith(discardedCard);
				
				var seatView:SeatView = getSeatByPlayerId(playerId);
				var playerName:String = (seatView.seatImpl && seatView.seatImpl.player) ? seatView.seatImpl.player.name : null;
				if(_dealImpl)
					_discardedCardView.addDiscardedCard(discardedCard, playerName, _dealImpl.joker.card.rank);
			}
		}
		
		override protected function onCardsDealComplete(e:Event=null, isSpectator:Boolean=false):void
		{
			super.onCardsDealComplete(e, isSpectator);
			_closedDeckArea.visible	= true;
			//_openDeckText.visible	= true;
			//_closedDeckText.visible = true;
			
			if (!_dealImpl)
				return;
			
			setJoker(); // NOTE: always set the joker before meld area and other
			setClosedDeck(false);
			_openDeckArea.updateDeck();
			setMeldArea();
		}
		
		override protected function onHandCardsTouched(event:HandCardIndicatorTouchedEvent):void
		{
			super.onHandCardsTouched(event);
			
			if (_meldArea)
			{
				_meldArea.setHandCards(_meldArea.getHandCards());
				if (mySeat)
					 mySeat.toggleShowHandCards(false);
			}
		}
		
		public function setJoker():void
		{
			_jokerArea.removeChildren();
			
			var joker:CardImpl = _dealImpl && _dealImpl.joker ? _dealImpl.joker.card : new CardImpl();
			var jokerFace:Ace2JakCard = Ace2JakCard.manufacture(joker.suit, joker.rank, true);
			_jokerArea.addChild(jokerFace);
			jokerFace.toggleDropShadow(true);
			//jokerFace.scaleX = jokerFace.scaleY	= 0.8;
			ScaleUtils.applyPercentageScale(jokerFace, 10, 21);
			jokerFace.rotation = 270 * (Math.PI / 180); // 90 degree CCW
			jokerFace.x -= jokerFace.width+jokerFace.width/3;
			jokerFace.y += jokerFace.height/2 - 15;
		}
		
		public function setClosedDeck(isCenter:Boolean):void
		{
			_closedDeckArea.removeChildren();
			
			var cardBack:Ace2JakCard = Ace2JakCard.manufactureClosedDeck();
			cardBack.toggleDropShadow(true);
			_closedDeckArea.x = WIDTH/2- cardBack.width;
			_closedDeckArea.y = (HEIGHT-cardBack.height)/2 -15; 
			_closedDeckArea.addChild(cardBack);
			
			_openDeckArea.x = WIDTH/2+ cardBack.width/4;
			_openDeckArea.y = HEIGHT/2 - cardBack.height/2 -15; 
			
			_declareDeck.x	= _openDeckArea.x + cardBack.width + 10;
			_declareDeck.y	= _openDeckArea.y;
			
		/*	if(isCenter)
			{
				_closedDeckArea.x = (Constants.TARGET_WIDTH-cardBack.width)/2;
				_closedDeckArea.y = (Constants.TARGET_HEIGHT-cardBack.height)/2;
			}
			else
			{
				var gameScreen:XML = MangoAssetManager.I.gameElements;
				_closedDeckArea.x = gameScreen.theme.closedDeck.@x;
				_closedDeckArea.y = gameScreen.theme.closedDeck.@y;
			}*/
		}
		
		public function setMeldArea():void
		{
			if (_handCardsImpl)
				_meldArea.setHandCards(_handCardsImpl);
		}
		
		override protected function onRejoinSeatShuffle(seats:Array, isRejoined:Boolean, leftPlayers:Array, match:MatchImpl):void
		{
			super.onRejoinSeatShuffle(seats, isRejoined, leftPlayers, match);
			
			var seatImpl:SeatImpl;
			var player:PlayerImpl;
			var leftPlayerId:Number;
			
			var dealerSeatId:int;
			for(var i:int=0; i<seats.length; i++)
			{
				seatImpl		= seats[i];
				player			= seatImpl.player;
				
				if(player)
				{ 
					dealerSeatId	= seatImpl.seatId; // Server sending last seat as a dealer seat
					
					if(leftPlayers.length >0)
					{
						for(var j:int=0; j<leftPlayers.length; j++)
						{
							leftPlayerId	= leftPlayers[j];
							if(player.id == leftPlayerId)
								(seats[i] as SeatImpl).player	= null;
						}
					}
				}
			}
			makeSeatsRepositions(seats, dealerSeatId, match, isRejoined);
		}
		
		override protected function onSeatShuffle(seats:Array):void
		{
			super.onSeatShuffle(seats);
			// disable the leavetable/ drop buttons until match starts
			onDisableLeaveBtn();
			
			var cardsInstances:Vector.<Ace2JakCard>	= new Vector.<Ace2JakCard>();
			var gameScreen:XML = MangoAssetManager.I.gameElements;
			var highestCardRank:int;
			var dealerSeatId:int;
			var isSet:Boolean;
			var highlightCard:CardImpl;
			
			for(var i:int=0; i<seats.length; i++)
			{
				var seatImpl:SeatImpl = seats[i];
				var player:PlayerImpl	= seatImpl.player;
				var card:CardImpl		= seatImpl.card;
				
				if(player && card)
				{
					if(!isRandomizerDone)
					{
						setClosedDeck(true);
						isRandomizerDone	= true;
						trace("Currentturn  seatShuffle --- >>>" + seatImpl.seatId);
					}
					dealerSeatId	= seatImpl.seatId; // Server sending last seat as a dealer seat
					if(!highlightCard)
						highlightCard	= card;
					processNextCard(player.id, card);
				}
			}
			
			var tempCard:Ace2JakCard;
			
			for(i=0; i<cardsInstances.length; i++)
			{
				tempCard	= cardsInstances[i];
				if(tempCard.rank == highlightCard.rank && tempCard.suit == highlightCard.suit)
				{
					var glowFilter:GlowFilter	= new GlowFilter(Color.YELLOW, 1, 10);
					tempCard.filter = glowFilter;//BlurFilter.createGlow(Color.YELLOW, 1, 25, 1);
				}
			}
			
			
			function processNextCard(playerId:Number, card:CardImpl):void
			{
				var seat:SeatView	= getSeatByPlayerId(playerId);
				if(!seat)
					return;
				
				var cardTobeDelt:Ace2JakCard = Ace2JakCard.manufacture(card.suit, card.rank, false);

				cardTobeDelt.pivotX = cardTobeDelt.width / 2;
				cardTobeDelt.pivotY = cardTobeDelt.height / 2;
				
				cardTobeDelt.scaleX = 0.85;
				cardTobeDelt.scaleY = 0.85
				
				cardTobeDelt.x	= gameScreen.theme.closedDeck.@x;
				cardTobeDelt.y	= gameScreen.theme.closedDeck.@y;
				
				addChild(cardTobeDelt);
				
				cardsInstances.push(cardTobeDelt);
				
				_seatingPos++;
				
				// card animation
				var cardTween:Tween = new Tween(cardTobeDelt, 1, Transitions.EASE_OUT);
				cardTween.moveTo(seat.randomiserCardPosX, seat.randomiserCardPosY);
				
				Starling.juggler.add(cardTween);
				
				cardTween.onComplete = function():void
				{
					Starling.juggler.remove(cardTween);
				};
			}
			
			if(isRandomizerDone)
			{
				// respositioing the seats after 2 seconds 
				Starling.juggler.delayCall( function ():void {
					// removing open cards
					for(i=0; i<cardsInstances.length; i++)
					{
						removeChild(cardsInstances[i]);
					}
					cardsInstances	= null;
					_closedDeckArea.removeChildren();
					
					makeSeatsRepositions(seats, dealerSeatId)
					
				}, 2.5);
			}
		}
		
		
		override public function checkingForValidShow():Boolean
		{
			var isValid: Boolean		= super.checkingForValidShow();
			var cardsLen:int			= 0;
			var groupCardsArray:Array	= _meldArea.getHandCards().groupcards;
			
			for(var i:int=0; i<groupCardsArray.length; i++)
			{
				cardsLen	+= groupCardsArray[i].card.length;
			}
			
			if(isValid && cardsLen == 14)
				return true;
			else
				return false;
		}
		
		
		
		override public function get canDrop():Boolean { return super.canDrop && !_newCardReceived; }
		
		public function get canDeclare():Boolean { return _canDeclare && _newCardReceived && _meldArea.oneCardSelected; }
		public function get meldArea():MeldAreaView { return _meldArea; }
		public function get closedDeck():ClosedDeckView { return _closedDeckArea; }
		public function get jokerArea():Sprite { return _jokerArea; }
		public function get openDeck():OpenDeckView { return _openDeckArea; }
		public function get declareArea():DeclareView { return _declareDeck; }
		public function get aboutToDeclare():Boolean { return _aboutToDeclare; }
	}
}