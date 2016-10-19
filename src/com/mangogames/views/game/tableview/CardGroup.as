package com.mangogames.views.game.tableview
{	
	import com.mangogames.services.SFSInterface;
	
	import flash.geom.Rectangle;
	
	import starling.display.Button;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	
	import utils.DrawShapeUtil;
	import utils.Fonts;
	import utils.IMangoCard;
	
	public class CardGroup
	{
		private const CARD_GAP:int = 30;
		
		private var _cards:Vector.<IMangoCard>;
		
		private var _posX:int;
		private var _posY:int;
		public var addHereButton:Button;
		public var numberOfCardSelected:int = 0;
		
		public var lastCardPickedGroup:Boolean;
		public var isSingleCard:Boolean;

		
		public function CardGroup()
		{
			_cards = new Vector.<IMangoCard>();
			
			//addChild(_groupButton);
//			_groupButton.visible = false;
//			_groupButton.addEventListener(Event.TRIGGERED, function (event:Event):void
//			{
//				_groupButton.visible = false;
//				
//				if(oneCardSelected)
//					return;
//				
//				dragStarted();
//				dragEnded();
//			});
			
		}
		
		public function assignCards(cards:Vector.<IMangoCard>, assignBeforeCard:CardView):void
		{
			var newList:Vector.<IMangoCard> = cards.slice();
			for (var i:int = 0; i < newList.length; i++)
			{
				var card:CardView = CardView(newList[i]);
				addCard(card, assignBeforeCard, false);
				
				assignBeforeCard = card; // next card will stack on top of it
			}
			newList = null;
		}
		
		public function addCard(card:CardView, addBeforeCard:CardView, forceLast:Boolean):void
		{
			// remove from old group and assign to this
			if (card.assignedGroup)
				card.assignedGroup.removeCard(card);
			card.assignedGroup = this;
			
			if (addBeforeCard)
			{
				// if add-before-card is provided then add it on top of it
				var index:int = _cards.indexOf(addBeforeCard);
				_cards.splice(index + 1, 0, card);
			}
			else if (forceLast)
			{
				// add it to the last location only if it is forced
				_cards.push(card);
			}
			else
			{
				// otherwise add it to the first most location
				_cards.unshift(card);
			}
		}
		
		public function removeCard(card:CardView):void
		{
			_cards.splice(_cards.indexOf(card), 1);
			card.assignedGroup = null;
			arrangeCards(true);
		}
		
		public function moveTo(posX:Number, posY:Number):void
		{
			if (_cards.length < 1)
				return;
			
			_posX = posX;
			_posY = posY;
			
			arrangeCards(true);
			
		}
		
		public function arrangeCards(transition:Boolean):void
		{
			if (!hasCards)
				return;
			
			// if no pos given then use first most card's pos to arrange the remaining cards
			var card:CardView = CardView(_cards[0]);
			
			var xPos:int = _posX;
			for (var i:int = 0; i < _cards.length; i++)
			{
				CardView(_cards[i]).moveTo(xPos, _posY, transition);
				//xPos += card.rank == 9 ? card.width/3 + 8: card.width/3; //CARD_GAP;
				if(card.rank == 9)
				{
					xPos += card.width/3 + 10;
				}
				else
				{
					xPos += card.width/3;
				}
			}
		}
		
		public function getBounds():Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			if (!hasCards)
				return bounds;
			
			var oneCard:CardView = CardView(_cards[0]);
			
			bounds.x = _posX;
			bounds.y = _posY;
			bounds.width = oneCard.card.width + ((_cards.length - 1) * oneCard.width/3); ////CARD_GAP);
			bounds.height = oneCard.card.height;
			
			return bounds;
		}
		
		public function isOverlapping(group:CardGroup):Boolean
		{
			if (this.getBounds().intersects(group.getBounds()))
				return true;
			
			return false;
		}
		
		public function getOverlappedCard(group:CardGroup):CardView
		{
			var groupBounds:Rectangle = group.getBounds();
			for (var i:int = _cards.length - 1; i >= 0; i--)
			{
				var card:CardView = CardView(_cards[i]);
				var cardBounds:Rectangle = new Rectangle(card.x, card.y, card.card.width, card.card.height);
				if (cardBounds.contains(groupBounds.x, card.y + 5 /*groupBounds.y*/)) // HACK: to fix issue with y sorting
					return card;
			}
			
			// send the last card if card's bound exceeding it
			if (card && groupBounds.x > card.x)
				return card;
			
			// the group is before all cards
			return null;
		}
		
		public function putCardsOver(card:CardView):void
		{
			if (!card.parent)
				return;
			
			var cardIndex:int = card.parent.getChildIndex(card);
			for each (var cardInGroup:CardView in _cards)
			{
				cardInGroup.parent.setChildIndex(cardInGroup, ++cardIndex);
			}
		}
		
		public function getAllCards():Vector.<IMangoCard>
		{
			var cards:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			for (var i:int = 0; i < _cards.length; i++)
			{
				cards.push(CardView(_cards[i]));
			}
			return cards;
		}
		
		public function getCardImpls():Array
		{
			var impls:Array = new Array();
			for (var i:int = 0; i < _cards.length; i++)
			{
				impls.push(CardView(_cards[i]).cardImpl);
			}
			return impls;
		}
		
		public function highlight(title:String, width:int, height:int):Sprite
		{
			// add bg
			var bgWithBorder:QuadBatch = DrawShapeUtil.getBoxWithBorder(width, height);
			var bg:Sprite = new Sprite();
			bg.addChild(bgWithBorder);
			
			// add title
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, 12, Color.WHITE);
			var label:TextField = new TextField(1, 1, title, tf );
			label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			label.format.bold	= true;
			bg.addChild(label);
			label.x = (bg.width - label.width) / 2;
			label.y = 0;
			bgWithBorder.y = label.height;
			
			bg.touchable = false;
			return bg;
		}
		
		public function gatherAtOnePoint():void
		{
			for (var i:int = 0; i < _cards.length; i++)
			{
				var card:CardView = CardView(_cards[i]);
				card.x = _posX;
				card.y = _posY;
			}
		}
		
		public function onAddHere(event:Event):void
		{
			SFSInterface.getInstance().FocusedRoom.gameView.tableView.meldArea.onAddHereWithGroup(this);
		}
		
		public function get hasCards():Boolean { return _cards.length > 0; }
		public function get cards():Vector.<IMangoCard> { return _cards; }
		public function get posX():int { return _posX; }
		public function set posX(value:int):void { _posX = value; }
		public function get posY():int { return _posY; }
		public function set posY(value:int):void { _posY = value; }
		
		public static function createGroupWihCards(cards:Vector.<IMangoCard>):CardGroup
		{
			var group:CardGroup = new CardGroup();
			group.assignCards(cards, null);
			//group.arrangeCards(false);
			return group;
		}
	}
}