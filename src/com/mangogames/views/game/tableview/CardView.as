package com.mangogames.views.game.tableview
{
	import com.mangogames.events.CardTouchedEvent;
	import com.mangogames.rummy.model.impl.CardImpl;
	
	import flash.geom.Point;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import utils.Ace2JakCard;
	import utils.IMangoCard;
	
	public class CardView extends Sprite implements IMangoCard
	{
		public static const TRANSITION_TYPE:String = Transitions.EASE_OUT;
		public static const TRANSITION_TIME:Number = 0.5;
		
		public var assignedGroup:CardGroup;
		
		private var _cardImpl:CardImpl;
		private var _card:Ace2JakCard;
		
		public function CardView()
		{
			super();
			
			// each card will respond to their own touch event
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function initCard(cardImpl:CardImpl, isJoker:Boolean, isFromScoreBoard:Boolean=false):void
		{
			_cardImpl = cardImpl
			
			_card = _cardImpl.ispaperjoker > 0
				? Ace2JakCard.manufacturePaperJoker(_cardImpl.suit, _cardImpl.rank, isPaperJoker, isFromScoreBoard)
				: Ace2JakCard.manufacture(_cardImpl.suit, _cardImpl.rank, isJoker, isFromScoreBoard);
			toggleDropShadow(true);
			addChild(_card);
		}
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			if (assignedGroup)
				assignedGroup.removeCard(this);
			_card.removeFromParent(true);
			
			super.dispose();
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if (!touch)
				return;
			
			if (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.ENDED)
			{
				// notify about the touch
				var cardTouchedEvent:CardTouchedEvent = new CardTouchedEvent(CardTouchedEvent.CARD_TOUCHED);
				cardTouchedEvent.touchedCard = this;
				cardTouchedEvent.phase = touch.phase;
				var localPos:Point = globalToLocal(new Point(touch.globalX, touch.globalY));
				cardTouchedEvent.touchedOffsetX = localPos.x;
				cardTouchedEvent.touchedOffsetY = localPos.y;
				dispatchEvent(cardTouchedEvent);
			}
		}
		
		public function moveTo(posX:Number, posY:Number, transition:Boolean):void
		{
			if (transition)
			{
				var tween:Tween = new Tween(this, TRANSITION_TIME, TRANSITION_TYPE);
				tween.moveTo(posX, posY);
				Starling.juggler.add(tween);
			}
			else
			{
				x = posX;
				y = posY;
			}
		}
		
		public function highlight():void
		{
			_card.highlight();
		}
		
		public function stopHighlight():void
		{
			_card.stopHighlight();
		}
		
		public function toggleDropShadow(value:Boolean):void
		{
			_card.toggleDropShadow(value);
		}
		
		public function get cardImpl():CardImpl { return _cardImpl; }
		public function get suit():int { return _cardImpl.suit; }
		public function get rank():int { return _cardImpl.rank; }
		public function get isPaperJoker():int { return _cardImpl.ispaperjoker; }
		public function get card():Ace2JakCard { return _card; }
	}
}