package com.mangogames.views.game.tableview
{
	import com.mangogames.events.CardTouchedEvent;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.GroupCardsImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.views.AbstractBaseView;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import logger.Logger;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import utils.IMangoCard;
	import utils.ObjectUtils;
	import utils.ScaleUtils;
	import utils.Sorter;
	
	public class MeldAreaView extends Sprite
	{
		private const DRAG_START_THRESHOLD:Number = 30;
		private const GROUP_GAP:int = 3;
		private const ALLOW_HIGHLIGHT:Boolean = false; // set it true to highlight sorted groups
		
		
		private var _cardGroups:Vector.<CardGroup>;
		private var _selectedCards:Vector.<IMangoCard>;
		private var _selectedGroup:CardGroup;
		private var _newReceivedCardImpl:CardImpl; // just to hold the new card
		private var _cardContainer:Sprite;
		private var _isDragging:Boolean;
		private var _touchedStartPosition:Point;
		private var _immediateSelection:CardView;
		private var _dragOffsetX:int;
		private var _dragOffsetY:int;
		
		private var _indicatorArea:Sprite;
		private var _discardButton:Button;
		private var _groupButton:Button;
		
		private var _table:RummyTableView;
		
		private var _isFolded:Boolean;
		private var _isCardAnimationStarted:Boolean;
		public var xPos_disacardedcard:int = -1;;
		public var yPos_discardedCard:int = -1;
		public var _isDeclared:Boolean;
		private var _isSubmitted:Boolean;
		public var _isAutoDeclared:Boolean;
		private var _isGroupIdentified:Boolean;
		private var _isSingleCardPicked:Boolean;
		
		private var WIDTH:int;
		private var HEIGHT:int;
		
		public function MeldAreaView(table:RummyTableView, indicatorArea:Sprite)
		{
			super();
			
			_table = table;
			
			var obj:Object	= AbstractBaseView.getStageSize();
			WIDTH			= obj.stageWidth;
			HEIGHT			= obj.stageHeight;
			
			_indicatorArea = indicatorArea;
			_cardGroups = new Vector.<CardGroup>();
			_isFolded = false;
			_isCardAnimationStarted = false;
			resetSelection();
			
			_discardButton = new Button(MangoAssetManager.I.getTexture("discards_btn"));
			addChild(_discardButton);
			/*_discardButton.width /= 2;
			_discardButton.height /= 2;*/
			ScaleUtils.applyPercentageScale(_discardButton, 6.5, 9);
			_discardButton.visible = false;
			_discardButton.addEventListener(Event.TRIGGERED, function (event:Event):void
			{
				_discardButton.visible = false;
				if (!oneCardSelected)
					return;
				if(_table.isJoinedFromMyTable)
				{
					var cardsLen:int			= 0;
					var groupCardsArray:Array	= getHandCards().groupcards;
					
					for(var i:int=0; i<groupCardsArray.length; i++)
					{
						cardsLen	+= groupCardsArray[i].card.length;
					}
					if(cardsLen == 14)
						_table.isAlreadyPickedCard	= true;
				}
				var card:CardView = CardView(_selectedCards[0]);
				discardCard(card);
			});
			
			_groupButton = new Button(MangoAssetManager.I.getTexture("GroupBtn"));
			addChild(_groupButton);
			ScaleUtils.applyPercentageScale(_groupButton, 6.5, 9);
			_groupButton.visible = false;
			_groupButton.addEventListener(Event.TRIGGERED, function (event:Event):void
			{
				_groupButton.visible = false;
				
				if(oneCardSelected)
					return;
				
				dragStarted();
				dragEnded();
			});
		}
		
		override public function dispose():void
		{
			clearMeldArea();
			_cardContainer.removeFromParent(true);
			_cardGroups = null;
			_selectedCards = null;
			_selectedGroup = null;
			_immediateSelection = null;
			super.dispose();
		}
		
		public function populate(handCards:Vector.<Vector.<IMangoCard>>):void
		{
			for (var i:int = 0; i < handCards.length; i++)
			{
				var groupCards:Vector.<IMangoCard> = handCards[i];
				var group:CardGroup = CardGroup.createGroupWihCards(groupCards);
				_cardGroups.push(group);
			}
			arrangeCardsInGroup();
		}
		
		public function setHandCards(handCards:HandCardsImpl):void
		{
			clearMeldArea();
			
			for (var i:int = 0; i < handCards.groupcards.length; i++)
			{
				var groupCards:GroupCardsImpl = handCards.groupcards[i];
				var cardVec:Vector.<IMangoCard> = new Vector.<IMangoCard>();
				for (var j:int = 0; j < groupCards.card.length; j++)
				{
					var cardImpl:CardImpl = groupCards.card[j];
					cardVec.push(addCard(cardImpl));
				}
				var group:CardGroup = CardGroup.createGroupWihCards(cardVec);
				group.posX = _table.width / 2 - CardView(cardVec[0]).card.width;
				group.posY = _handCardsPosY; //MangoAssetManager.I.gameElements.theme.meldArea.@y;
				group.gatherAtOnePoint();
				_cardGroups.push(group);
			}
			arrangeCardsInGroup();
		}
		
		public function getHandCards():HandCardsImpl
		{
			var handCards:HandCardsImpl = new HandCardsImpl();
			for (var i:int = 0; i < _cardGroups.length; i++)
			{
				if (!_cardGroups[i].hasCards)
					continue;
				
				var groupCards:GroupCardsImpl = new GroupCardsImpl();
				groupCards.card = _cardGroups[i].getCardImpls();
				handCards.groupcards.push(groupCards);
			}
			return handCards;
		}
		
		public function getHandCardsWithSelctedCards():HandCardsImpl
		{
			var dontInclude:Boolean;
			
			var handCards:HandCardsImpl = new HandCardsImpl();
			for (var i:int = 0; i < _cardGroups.length; i++)
			{
				var groupCards:GroupCardsImpl = new GroupCardsImpl();
				
				if((_cardGroups[i].isSingleCard || _cardGroups[i].lastCardPickedGroup) && _isAutoDeclared && _selectedCards.length == 1)
				{
					dontInclude	= true;
					_cardGroups[i].lastCardPickedGroup	= false;
					_cardGroups[i].isSingleCard			= false;
					_cardGroups[i].cards.unshift(CardView(_selectedCards[0]));
				}
				
					groupCards.card = _cardGroups[i].getCardImpls();
					if(groupCards.card.length >0)
						handCards.groupcards.push(groupCards);
			}
			
			// push selected dragging cards
			if((!dontInclude && _selectedCards && _selectedCards.length >1) && (_selectedGroup && _selectedGroup.cards && _selectedGroup.cards.length >0))
			{
				groupCards 			= new GroupCardsImpl();
				groupCards.card		= _selectedGroup.getCardImpls();
				handCards.groupcards.push(groupCards);
			}
			
			return handCards;
		}
		
		public function toIMangoCardGroups():Vector.<Vector.<IMangoCard>>
		{
			var cardGroups:Vector.<Vector.<IMangoCard>> = new Vector.<Vector.<IMangoCard>>();
			for (var i:int = 0; i < _cardGroups.length; i++)
			{
				cardGroups.push(_cardGroups[i].cards);
			}
			return cardGroups;
		}
		
		public function clearMeldArea():void
		{
			resetSelection();
			
			if (_cardGroups)
			{
				for (var i:int = 0; i < _cardGroups.length; i++)
				{
					for (var j:int = 0; j < _cardGroups[i].cards.length; j++)
					{
						var card:CardView = CardView(_cardGroups[i].cards[j]);
						removeCard(card);
					}
				}
			}
			
			removeChild(_discardButton);
			removeChild(_groupButton); // removed
			removeChildren(0, -1, true);
			_indicatorArea.removeChildren(0, -1, true);
			_cardContainer = new Sprite();
			addChild(_cardContainer);
			addChild(_discardButton);
			addChild(_groupButton);// added again
			_cardGroups = new Vector.<CardGroup>();
			_table.openDeck.stopHighlight();
			_table.declareArea.stopHighlight();
			_discardButton.visible = false;
			_groupButton.visible = false; // invisible
			_newReceivedCardImpl = null;
			_isDeclared			 = false;
			_isSubmitted		 = false;
			_isAutoDeclared		 = false;
		}
		
		private function discardCard(card:CardView):void
		{
			var localPos:Point = localToGlobal(new Point(card.x, card.y));
			
			xPos_disacardedcard = localPos.x;
			yPos_discardedCard = localPos.y;
			
			// discard only if the player has picked a card
			if (!card || !_newReceivedCardImpl)
				return;
			
			var cardImpl:CardImpl = card.cardImpl;
			removeCard(card); // remove locally
			
			SFSInterface.getInstance().cardDiscarded(cardImpl, _table.gameView.room); // notify server
			
			_newReceivedCardImpl = null;
			
			resetSelection();
			removeEmptyGroups();
			arrangeCardsInGroup();
		}
		
		public function prepareForDeclare(card:CardView):void
		{
			removeCard(card); // remove locally
			
			resetSelection();
			removeEmptyGroups();
			arrangeCardsInGroup();
		}
		
		public function declareCards(isFinalDeclare:Boolean):void
		{
			if(isFinalDeclare)
			{
				_table.gameView.stopcountdownSignal.dispatch();
				_table.onDisableLeaveBtn();
				_isDeclared	= true;
				// hiding addhere button if any
				removeAddHereButtonsIfAny();
			}
			
			var card:CardImpl = _table.declareArea.cardImpl;
			if(card)
			{
				Logger.log("declaring with card, rank: " + card.rank + ", suit: " + card.suit  + "  isFinalDeclare "+ isFinalDeclare);
				//SFSInterface.getInstance().declare(getHandCards(), card, _table.gameView.room, isFinalDeclare);
				SFSInterface.getInstance().declare(getHandCardsWithSelctedCards(), card, _table.gameView.room, isFinalDeclare);
			}
		}
		
		public function removeAddHereButtonsIfAny():void
		{
			if(_cardGroups)
			{
				for (var i:int = 0; i < _cardGroups.length && _cardGroups[i].addHereButton; i++)
				{
					_cardGroups[i].addHereButton.visible = false;
				}
			}
		}
		
		public function disableGroupBtnsIfAny():void
		{
			_groupButton.visible	= false;
		}
		
		public function addNewCard(cardImpl:CardImpl):CardView
		{
			_newReceivedCardImpl = cardImpl;
			return injectCard(_newReceivedCardImpl);
		}
		
		public function discardNewCard():void
		{
			if (!_newReceivedCardImpl)
				return;
			
			// simulate a drag ending sequence
			dragEnded();
			
			// since we are rebuilding all the cards from the scratch
			// everytime we are sorting, we shall search via cardImpl
			// for the match, the side effect is that if we have two of
			// the same card, the first one encountered will be removed
			for (var i:int = 0; i < _cardGroups.length; i++)
			{
				for (var j:int = 0; j < _cardGroups[i].cards.length; j++)
				{
					var cardView:CardView = CardView(_cardGroups[i].cards[j]);
					if (cardView.rank == _newReceivedCardImpl.rank &&
						cardView.suit == _newReceivedCardImpl.suit)
					{
						discardCard(cardView);
						return;
					}
				}
			}
		}
		
		public function removeSelectedCards():void
		{
			for (var i:int = 0; i < _selectedCards.length; i++)
				removeCard(CardView(_selectedCards[i]));
			
			resetSelection();
			removeEmptyGroups();
			arrangeCardsInGroup();
		}
		
		public function injectCard(cardImpl:CardImpl):CardView
		{
			var injectedCard:CardView = addCard(cardImpl);
			var cardVec:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			cardVec.push(injectedCard);
			
			var group:CardGroup = CardGroup.createGroupWihCards(cardVec);
			_cardGroups.push(group);
			
			resetSelection();
			removeEmptyGroups();
			arrangeCardsInGroup();
			
			return injectedCard;
		}
		
		// listens handcard touch
		private function onCardTouched(event:CardTouchedEvent):void
		{
			// ignore any click on cards while dargging, submitted and declared
			if(_isDeclared || _isDragging || _isSubmitted) return;
			
			// ignore any click on cards while darg has started
			/*if (_isDragging)
				return;*/
			
			if (_isFolded)
			{
				if (event.phase == TouchPhase.ENDED)
					fold();
				return;
			}
			
			var card:CardView = event.touchedCard;
			var cardSelected:Boolean = isCardSelected(card);
			switch (event.phase)
			{
				case TouchPhase.BEGAN:
					if (!cardSelected) // only select if not selected
					{
						selectCard(card);
						_immediateSelection = card;
					}
					_dragOffsetX = event.touchedOffsetX;
					_dragOffsetY = event.touchedOffsetY;
					break;
				
				case TouchPhase.ENDED:
					// only deselect if touch ended has happened in next cycle
					if (cardSelected && _immediateSelection != card)
						deselectCard(card);
					_immediateSelection = null;
					break;
			}
		}
		
		private function isCardSelected(card:CardView):Boolean
		{
			for (var i:int = 0; i < _selectedCards.length; i++)
			{
				if (card == _selectedCards[i])
					return true; // card already selected
			}
			return false;
		}
		private var ALLOW_CARD_GROUP_LENGTH:int	= 5;
		
		private function selectCard(card:CardView):void
		{
			card.highlight();
			var closeCard:Object	= ObjectUtils.clone(card);
			if(_table.isJoinedFromMyTable && !_table.isShowInitiated)
			{
				var cardsLen:int			= 0;
				var groupCardsArray:Array	= getHandCards().groupcards;
				
				for(var i:int=0; i<groupCardsArray.length; i++)
				{
					cardsLen	+= groupCardsArray[i].card.length;
				}
				
				if(cardsLen == 14)
					_table.isForceShowBtnEnable	= true;
			}
//			if(card.y == MangoAssetManager.I.gameElements.theme.meldArea.@y)
//				card.y += 10;
			var yPosition:Number = _handCardsPosY; //MangoAssetManager.I.gameElements.theme.meldArea.@y;
			card.y = yPosition + 10;
			showAddHereButtonAfterSelection(card);
			_selectedCards.push(card);
			
			_discardButton.visible = oneCardSelected && newReceivedCard && !_table.aboutToDeclare;
			_discardButton.x = _discardButton.visible ? CardView(_selectedCards[0]).x + (CardView(_selectedCards[0]).width - _discardButton.width) / 2 : 0;
			_discardButton.y = _discardButton.visible ? CardView(_selectedCards[0]).y - _discardButton.height  : 0;
			
			trace("XXXXXXXXX   CardGroups Length " + _cardGroups.length);
			_groupButton.visible = !oneCardSelected && _cardGroups.length<5;
			_groupButton.x = _groupButton.visible ? CardView(_selectedCards[_selectedCards.length - 1]).x + (CardView(_selectedCards[_selectedCards.length - 1]).width - _groupButton.width) / 2 : 0;
			_groupButton.y = _groupButton.visible ? CardView(_selectedCards[_selectedCards.length - 1]).y - _groupButton.height : 0;
			
			showAddHereButtonAfterSelection(card);
		}
		
		private function showAddHereButtonAfterSelection(card:CardView):void
		{
			for (var i:int = 0; i < _cardGroups.length; i++)
			{
				var group:CardGroup = _cardGroups[i];
				if(noCardSelected && card.assignedGroup != _cardGroups[i])
				{
					_cardGroups[i].addHereButton.x = _cardGroups[i].posX;
					_cardGroups[i].addHereButton.y = CardView(_cardGroups[i].cards[0]).y - _cardGroups[i].addHereButton.height - 5;
					_cardGroups[i].addHereButton.visible = true;
				}
				else if(card.assignedGroup == _cardGroups[i])
				{
					_cardGroups[i].addHereButton.visible = false;
					_cardGroups[i].numberOfCardSelected++;
				}
				
			}
		}
		
		private function deselectCard(card:CardView):void
		{
			card.stopHighlight();
			_table.isForceShowBtnEnable	= false
//			if(card.y > MangoAssetManager.I.gameElements.theme.meldArea.@y)
//				card.y -= 10;
			card.y = _handCardsPosY; //MangoAssetManager.I.gameElements.theme.meldArea.@y;
			
			_selectedCards.splice(_selectedCards.indexOf(card), 1);
			
			_discardButton.visible = oneCardSelected && newReceivedCard && !_table.aboutToDeclare;
			_discardButton.x = _discardButton.visible ? CardView(_selectedCards[0]).x + (CardView(_selectedCards[0]).width - _discardButton.width) / 2 : 0;
			_discardButton.y = _discardButton.visible ? CardView(_selectedCards[0]).y - _discardButton.height - 10 : 0;
			
			if (!noCardSelected)
			{
				_groupButton.visible = !oneCardSelected && _cardGroups.length<5;
				_groupButton.x = _groupButton.visible ? CardView(_selectedCards[0]).x + (CardView(_selectedCards[0]).width - _groupButton.width) / 2 : 0;
				_groupButton.y = _groupButton.visible ? CardView(_selectedCards[0]).y - _groupButton.height - 10 : 0;
			}
			
			if (card.assignedGroup)
				card.assignedGroup.numberOfCardSelected--;
			hideAddHereButton(card);
		}
		
		private function hideAddHereButton(card:CardView):void
		{
			if (noCardSelected)
			{
				for (var i:int = 0; i < _cardGroups.length && _cardGroups[i].addHereButton; i++)
				{
					_cardGroups[i].addHereButton.visible = false;
				}
			}
			else if (card.assignedGroup.addHereButton != null && card.assignedGroup.numberOfCardSelected == 0)
			{
				card.assignedGroup.addHereButton.x = card.assignedGroup.posX;
				card.assignedGroup.addHereButton.y = CardView(card.assignedGroup.cards[0]).y - card.assignedGroup.addHereButton.height - 5;
				card.assignedGroup.addHereButton.visible = true;
			}
		}
		
		public function onTouch(event:TouchEvent):void
		{
			// ignore any click/dragging on submitted and declared
			if(_isDeclared || _isSubmitted) return;
			
			var touch:Touch = event.getTouch(this);
			if (!touch)
				return;
			
			switch (touch.phase)
			{
				case TouchPhase.BEGAN:
					_touchedStartPosition = new Point(touch.globalX, touch.globalY);
					break;
				
				case TouchPhase.ENDED:
					if (_isDragging)
					{
						if (checkForDropOnOpenDeck(touch.globalX, touch.globalY) && _newReceivedCardImpl && !_table.isGamePaused)
						{
							// drop has been made on open deck area, discard the card
							discardCard(CardView(_selectedCards[0]));
						}
						else
						{
							dragEnded();
						}
						_isDragging = false;
					}
					break;
				
				case TouchPhase.MOVED:
					// a valid drag happens only if we have moved past the threshold
					if (_touchedStartPosition && !_isDragging)
					{
						var distanceSquare:Number = Math.pow((touch.globalX - _touchedStartPosition.x), 2) + Math.pow((touch.globalY - _touchedStartPosition.y), 2) 
							
							var distance:Number = Math.sqrt(distanceSquare);
//							((touch.globalX - _touchedStartPosition.x) * (touch.globalX - _touchedStartPosition.x)
//								+(touch.globalY - _touchedStartPosition.y) * (touch.globalY - _touchedStartPosition.y));
						if (distance > DRAG_START_THRESHOLD)
						{
							dragStarted();
							_isDragging = true;
						}
					}
					
					if (_isDragging)
					{
						moveSelectedGroupTo(touch.globalX - _dragOffsetX, touch.globalY - _dragOffsetY);
					}
					break;
			}
		}
		
		private function dragStarted():void
		{
			if (_selectedCards.length == 0)
				return;
			
			// create a group with selected cards
			// this is the group that we will drag around
			_selectedGroup = CardGroup.createGroupWihCards(_selectedCards);
			
			if(_selectedGroup.cards.length ==1)
			{
				var overlappedGroup:CardGroup;
				var overlappedCard:CardView;
				for (var i:int = 0; i < _cardGroups.length; i++)
				{
					if(!_cardGroups[i].hasCards && !_cardGroups[i].isSingleCard)
					{
						_cardGroups[i].isSingleCard	= true;
						_isSingleCardPicked			= true;
					}
				}
				
				// unmark the  all other card picked groups , when last or first single card group picked
				if(_isSingleCardPicked)
				{
					_isGroupIdentified	= false;
					for (i = 0; i < _cardGroups.length; i++)
					{
						_cardGroups[i].lastCardPickedGroup	= false;
					}
				}
			}
			// if this is my turn to discard and I have only one card in my hand
			// then highlight open deck area
			if (_newReceivedCardImpl && _selectedCards.length == 1 && !_table.isGamePaused)
				_table.openDeck.highlight();
		}
		
		private function dragEnded():void
		{
			_isGroupIdentified	= false;
			_isSingleCardPicked	= false;
			// none of the cards selected
			if (_selectedCards.length == 0)
				return;
			
			if (!!_table.isGamePaused)
				_table.openDeck.stopHighlight();
			
			// remove glow
			for (var i:int = 0; i < _selectedCards.length; i++)
			{
				CardView(_selectedCards[i]).stopHighlight();
			}
			
			// if the selected group is overlapping some other group then we
			// will merge it with that group otherwise we will left it as a new group
			if (_selectedGroup)
			{
				
				var overlappedGroup:CardGroup;
				var overlappedCard:CardView;
				for (i = 0; i < _cardGroups.length; i++)
				{
					if (_selectedGroup.isOverlapping(_cardGroups[i]))
					{
						overlappedGroup = _cardGroups[i];
						if(!_isAutoDeclared)
						{
							overlappedGroup.lastCardPickedGroup	= false;
						}
						
						overlappedCard = _cardGroups[i].getOverlappedCard(_selectedGroup);
						break;
					}
					_cardGroups[i].isSingleCard	= false;
				}
				
				if (overlappedGroup)
					overlappedGroup.assignCards(_selectedGroup.cards, overlappedCard);
				else
					_cardGroups.unshift(_selectedGroup); // add it to main list of group
				
			}
			
			resetSelection();
			removeEmptyGroups();
			arrangeCardsInGroup();
		}
		
		public function addOutsideDraggedCard():void
		{
			_isAutoDeclared	= true;
		}
		// these are the margins to restrict the card movement not to go beyond the margins
		private var leftMargin:int;
		private var rightMargin:int;
		private var bottomMargin:int;
		private var topMargin:int;
		
		
		private function moveSelectedGroupTo(posX:Number, posY:Number):void
		{
			var obj:Object	= AbstractBaseView.getStageSize();
			var Width:int	= obj.stageWidth;
			var Height:int	= obj.stageHeight;
			var cardVw:CardView = _selectedCards.length>0 ?CardView(_selectedCards[0]): null;
			
			if (!_selectedGroup)
				return;
			
			if(cardVw && leftMargin<=0 || rightMargin<0)
			{
				leftMargin	= cardVw.width/8;
				rightMargin	= Width-cardVw.width;
				bottomMargin= Height-cardVw.height;
				topMargin	= cardVw.height;
			}
			
			if(posX < leftMargin)
			{
				posX	= leftMargin;
			}
			else if(posX > rightMargin)
			{
				posX	= rightMargin;
			}
			else 
			{
				posX = posX;
			}
			if(posY <topMargin)
			{
				posY	= topMargin;
			}
			else if(posY > bottomMargin)
			{
				posY	=  bottomMargin;
			}
			else{
				posY = posY;
			}
			
			_selectedGroup.moveTo(posX - x, posY - y);
			
			if(!_isSingleCardPicked)
			{
				// check overlapping with other groups
				for (var i:int = 0; i < _cardGroups.length; i++)
				{
					if (_selectedGroup.isOverlapping(_cardGroups[i]))
					{
						if(!_cardGroups[i].lastCardPickedGroup && !_isGroupIdentified)
						{
							_isGroupIdentified	= true;
							//trace("XXXXXXXXXXXXXXXX  lastCardPickedGroup Index  " + i + "  true");
								_cardGroups[i].lastCardPickedGroup	= true;
						}
						// put all the selected cards over the last overlapped card
						var card:CardView = _cardGroups[i].getOverlappedCard(_selectedGroup);
						if (card)
						{
							_selectedGroup.putCardsOver(card);
						}
					}
				}
				
				// 
				if(_isGroupIdentified)
				{
					for (i= 0; i < _cardGroups.length; i++)
					{
						_cardGroups[i].isSingleCard	= false;
					}
				}
			}
	
		}
		
		private function checkForDropOnOpenDeck(posX:Number, posY:Number):Boolean
		{
			// only one card is selected and the drop has happened on open deck area
			if (_selectedCards.length == 1 && _table.openDeck.bounds.contains(posX, posY))
				return true;
			
			return false;
		}
		
		private function checkForDropOnDeclareArea(posX:Number, posY:Number):Boolean
		{
			// only one card is selected and the drop has happened on open deck area
			if (_selectedCards.length == 1 && _table.declareArea.bounds.contains(posX, posY))
				return true;
			
			return false;
		}
		
		private function resetSelection():void
		{
			if (_selectedCards)
			{
				for (var i:int = 0; _selectedCards.length != 0; i++)
				{
					deselectCard(CardView(_selectedCards[i]));
					i--;
				}
			}
			_selectedCards = new Vector.<IMangoCard>();
			_selectedGroup = null;
			if (_discardButton)
				_discardButton.visible = false;
			
			if (_groupButton)
				_groupButton.visible = false;
		}
		
		private function removeEmptyGroups():void
		{
			// this one removes all the empty groups and gathers all the singles at one place
			var singles:CardGroup = new CardGroup();
			for (var i:int = 0; i < _cardGroups.length; i++)
			{
				if (!_cardGroups[i].hasCards)
				{
					if (_cardGroups[i].addHereButton)
						_cardGroups[i].addHereButton.removeFromParent(true);
					_cardGroups.splice(i, 1);
					i--;
				}
				else if (_cardGroups[i].cards.length == 1)
				{
					if (_cardGroups[i].addHereButton)
						_cardGroups[i].addHereButton.removeFromParent(true);
					singles.addCard(CardView(_cardGroups[i].cards[0]), null, true);
					_cardGroups.splice(i, 1);
					i--;
				}
			}
			if (singles.hasCards)
				_cardGroups.push(singles);
		}
		
		private function arrangeCardZOrder(group:CardGroup, startIndex:int):void
		{
			for (var i:int = 0; i < group.cards.length; i++)
			{
				_cardContainer.addChildAt(CardView(group.cards[i]), startIndex + i);
			}
		}
		
		private function addCard(cardImpl:CardImpl):CardView
		{
			var cardView:CardView = new CardView();
			cardView.initCard(cardImpl, cardImpl.rank == _table.dealImpl.joker.card.rank);
			cardView.addEventListener(CardTouchedEvent.CARD_TOUCHED, onCardTouched);
			if(_cardContainer) _cardContainer.addChild(cardView);
			return cardView;
		}
		
		private function removeCard(card:CardView):void
		{
			if(card.assignedGroup)
			{
				_cardContainer.removeChild(card);
				card.removeEventListener(CardTouchedEvent.CARD_TOUCHED, onCardTouched);
				card.assignedGroup.removeCard(card);
				card.dispose();
				card = null;
			}
		}
		
		private var _handCardsPosY:int;
		private function arrangeCardsInGroup():void
		{
			Sorter.timeSnapShot(true);
			
			// partial clean up
			resetSelection();
			if(_cardContainer) removeChild(_cardContainer);
			removeChild(_discardButton);
			removeChild(_groupButton); // remove the group button
			removeChildren(0, -1, true);
			_indicatorArea.removeChildren(0, -1, true);
			if(_cardContainer) addChild(_cardContainer);
			addChild(_discardButton);
			addChild(_groupButton);  // adding group button again
			removeEmptyGroups();
			
			var cardHeight:int	= _cardGroups[0].getBounds().height;
			var posX:Number = 0;
			var posY:Number = HEIGHT-(cardHeight+10); //MangoAssetManager.I.gameElements.theme.meldArea.@y;
			_handCardsPosY	= posY;
			var totalWidth:Number = 0;
			var sortedGroupCount:int = 0;
			var startIndex:int = 0;
			for (var i:int = 0; i < _cardGroups.length; i++)
			{
				var group:CardGroup = _cardGroups[i];
				
				// sort cards by their z-order and then arrange them
				arrangeCardZOrder(group, startIndex);
				startIndex += group.cards.length;
				group.moveTo(posX, posY);
				group.arrangeCards(true);
				
				var bound:Rectangle = group.getBounds();
				
				// FIXME: is it feasible??
				var tryHighlight:int = tryHighlightGroup(group, posX, posY, bound.width, bound.height);
				sortedGroupCount += tryHighlight != Sorter.SORTTYPE_NONE ? 1 : 0;
				
				_cardGroups[i].addHereButton = new Button(MangoAssetManager.I.getTexture("GroupBtn"));
				_cardGroups[i].addHereButton.x = posX;
				_cardGroups[i].addHereButton.y = CardView(_cardGroups[i].cards[0]).y - _cardGroups[i].addHereButton.height - 5;
				//addChild(_cardGroups[i].addHereButton);
				_cardGroups[i].addHereButton.addEventListener(Event.TRIGGERED, _cardGroups[i].onAddHere);
				_cardGroups[i].addHereButton.visible = false;
				//		}
				
				posX += bound.width + GROUP_GAP;
				
				// update total meld area width
				totalWidth += bound.width + GROUP_GAP;
			}
			
			// so we have 14 cards (including the new picked card) and all groups are sorted
			// except the one with only one card which we are going to discard, we are all set for declaring
			/**
			 * COMMENTING FOLLOWING BLOCKS AS PER CLIENT REQUEST
			 */
			/* 
			_canDeclare = false;
			if (sortedGroupCount == _cardGroups.length - 1 
			&& _cardGroups[_cardGroups.length - 1].cards.length == 1 
			&& _newReceivedCardImpl)
			{
			_canDeclare = true;
			}
			*/
			
			// remove one extra gap added at the last
			//if (totalWidth != 0)
			//	totalWidth -= GROUP_GAP;
			
			// position the meld area to the center of the screen
			this.x = (WIDTH - totalWidth) / 2 + 10;
			//this.y	= HEIGHT - bound.height;
			_indicatorArea.x = this.x;
			Sorter.timeSnapShot();
		}
		
		public function onAddHereWithGroup(addGroup:CardGroup):void
		{
			dragStarted();
			
			if (_selectedCards.length == 0)
				return;
			
			if (!!_table.isGamePaused)
				_table.openDeck.stopHighlight();
			
			// remove glow
			for (var i:int = 0; i < _selectedCards.length; i++)
			{
				CardView(_selectedCards[i]).stopHighlight();
			}
			
			// if the selected group is overlapping some other group then we
			// will merge it with that group otherwise we will left it as a new group
			if (_selectedGroup)
			{
				var overlappedGroup:CardGroup = addGroup;
				var overlappedCard:CardView = CardView(addGroup.cards[addGroup.cards.length - 1]);
				
				overlappedGroup.assignCards(_selectedGroup.cards, overlappedCard);
			}
			
			resetSelection();
			removeEmptyGroups();
			arrangeCardsInGroup();
		}
		
		private function tryHighlightGroup(group:CardGroup, posX:int, posY:int, width:int, height:int):int
		{
			// FIXME: is it REALLY feasible!?
			const gap:int = 10;
			var isSorted:int = Sorter.isSorted(group.getAllCards(), _table.dealImpl.joker.card.rank);
			
			// try to put a bg around it
			if (ALLOW_HIGHLIGHT)
			{
				var title:String = null;
				switch (isSorted)
				{
					case Sorter.SORTTYPE_NONE: break; // nothing to do here
					case Sorter.SORTTYPE_PURE: title = "Pure"; break;
					case Sorter.SORTTYPE_IMPURE: title = "Impure"; break;
					case Sorter.SORTTYPE_SET: title = "Set"; break;
				}
				
				if (title != null)
				{
					var bg:Sprite = group.highlight(title, width + gap, height + gap);
					_indicatorArea.addChild(bg);
					bg.x = posX - gap / 2;
					bg.y = posY - 21;
				}
			}
			
			return isSorted;
		}
		
		public function predictLastCardPosition():int
		{
			// predicting the location for the last card
			if (_cardGroups.length < 1)
				return 0;
			
			var group:CardGroup = _cardGroups[_cardGroups.length - 1];
			if (group.cards.length < 1)
				return 0;
			
			var card:CardView = CardView(group.cards[group.cards.length - 1]);
			return card.x + card.card.width + x;
		}
		
		public function fold():void
		{
			_isFolded = true;
			var posX:int = width / 2;
			var posY:int = _handCardsPosY; //MangoAssetManager.I.gameElements.theme.meldArea.@y;
			if(_isCardAnimationStarted)
				return;
			// animate folding of cards
			_isCardAnimationStarted = true;
			for (var i:int = 0; i < _cardGroups.length; i++)
			{
				var group:CardGroup = _cardGroups[i];
				for (var j:int = 0; j < group.cards.length; j++)
				{
					var card:CardView = CardView(group.cards[j]);
					card.moveTo(posX - card.card.width / 2, posY, true);
				}
			}
			
			if (_table.mySeat)
				_table.mySeat.toggleShowHandCards(false);
			
			Starling.juggler.delayCall(onFold, CardView.TRANSITION_TIME + 0.2);
			function onFold():void
			{
				_cardContainer.visible = false;
				_isCardAnimationStarted = false;
				if (_table.mySeat && !_table.isMatchOver)
					_table.mySeat.toggleShowHandCards(true);
			}
		}
		
		public function toggleFoldCards(value:Boolean):void
		{
			_isFolded = value;
		}
		
		public function get oneCardSelected():Boolean { return _selectedCards.length == 1; }
		public function get noCardSelected():Boolean { return _selectedCards.length == 0; }
		public function get newReceivedCard():CardImpl { return _newReceivedCardImpl; }
		public function get isHandCardsAvailable():Boolean { return _cardGroups.length > 0; }
		public function get selectedCards():Vector.<IMangoCard> { return _selectedCards; }
		public function get isSubmitted():Boolean	{ return _isSubmitted }
		public function set isSubmitted(value:Boolean):void { _isSubmitted	= value };
	}
}