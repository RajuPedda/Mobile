package com.mangogames.views.game.tableview
{
	import com.mangogames.events.MenuEvent;
	import com.mangogames.managers.MangoAssetManager;
	
	import flash.utils.getTimer;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.utils.deg2rad;

	public class CardShuffleMachine extends Sprite
	{
		private var _machineTexture:Image = null;
	
		private var _previousOrientationIndex:int = -1;
		private var _possibleOrientations:Array = [-45, 0, 45, 90, 135, 175];
		
		private var _dealPositions:Array = null;
		private var _positionIterator:int = 0;
		
		private var _totalCardsToDeal:int = 0;
		private var _cardsDealt:int = 0;
		
		private var _lastCallTime:int; // last frame call time
		
		private var _tableView:TableView;
		
		private var _animPrefabInstances:Array = null;

		public function CardShuffleMachine(tableView:TableView)
		{
			_tableView = tableView;
			_animPrefabInstances = new Array();
		}
		
		public function init():void
		{
			_machineTexture = new Image(MangoAssetManager.I.getTexture("Back"));
			//_machineTexture.alpha = 0.001;
			//_machineTexture.scaleX = 0.5;
			//_machineTexture.scaleY = 0.5;
			
			if(Constants.TARGET_WIDTH == 2048)
			{
				_machineTexture.width = _machineTexture.width * 0.6;
				_machineTexture.height = _machineTexture.height * 0.6;
			}
			
			_machineTexture.x = this.x;
			_machineTexture.y = this.y;
			
			_machineTexture.pivotX = _machineTexture.width / 2;
			_machineTexture.pivotY = _machineTexture.height / 2;
			
			_machineTexture.alpha = 0;
			
			_tableView.addChild(_machineTexture);
		}
		
		public function startDeal(noOfCardsToDeal:int):void
		{
			_machineTexture.alpha = 0.001;

			_totalCardsToDeal = noOfCardsToDeal * _dealPositions.length;
			_cardsDealt = 0;
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:EnterFrameEvent):void
		{
			var now:int = getTimer();
			var elapsedTime:int = now - _lastCallTime;
			
			if(elapsedTime >= 200) // deal one card per second
			{
				_lastCallTime = now;
				
				dealNext();
				
				_cardsDealt++;
				
				if(_cardsDealt == _totalCardsToDeal)
				{
					var e:MenuEvent = new MenuEvent(MenuEvent.CARDS_DEAL_COMPLETE, null, true);					
					this.dispatchEvent(e);
					
					this.removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
				}
			}
		}
		
		private function dealNext():void
		{
			if(_dealPositions)
			{
				dealToPosition(_dealPositions[_positionIterator]);
				
				_positionIterator++;
				
				if(_positionIterator >= _dealPositions.length)
				{
					_positionIterator = 0;
				}
			}
		}
		
		public function set dealPositions(value:Array):void
		{
			_dealPositions = value;
		}
		
		private function dealToPosition(toPos:Array):void
		{
			var tween:Tween = new Tween(_machineTexture, 1, Transitions.EASE_OUT);
			
			var cardToBeDealt:Image = getCardToBeDealt();			
			_animPrefabInstances.push(cardToBeDealt);
			
			var tween2:Tween = new Tween(cardToBeDealt, 1, Transitions.EASE_OUT);
			
			var degree:Number = getNextOrientation()
			tween.animate("rotation", deg2rad(degree));
			
			//tween2.animate("rotation", deg2rad(degree));
			if(toPos)
			{
				tween2.animate("x", toPos[0]);
				tween2.animate("y", toPos[1]);
				
				Starling.juggler.add(tween);			
				Starling.juggler.add(tween2);
				
				tween.onComplete = function():void
				{
					Starling.juggler.remove(tween);
				};
				
				tween2.onComplete = function():void
				{
					Starling.juggler.remove(tween2);
					
					if(_cardsDealt == _totalCardsToDeal)
					{
						clearAnimPrefabInstances();
						
						_machineTexture.alpha = 0;
					}
				};
			}
		
		}
		
		private function getCardToBeDealt():Image
		{
			var closedCard:Image = new Image(MangoAssetManager.I.getTexture("Back"));
			if(Constants.TARGET_WIDTH == 2048)
			{
				closedCard.width = closedCard.width * 0.6;
				closedCard.height = closedCard.height * 0.6;
			}
			
			_tableView.addChild(closedCard);
			
			closedCard.x = _machineTexture.x;
			closedCard.y = _machineTexture.y + 10;
			
			/*closedCard.scaleX = 0.8;
			closedCard.scaleY = 0.8;*/
			closedCard.alpha = 0.001;
			return closedCard;
		}
		
		private function getNextOrientation():int
		{
			_previousOrientationIndex++;
			
			if(_previousOrientationIndex > _possibleOrientations.length)
			{
				_previousOrientationIndex = 0;					
			}
			
			return _possibleOrientations[_previousOrientationIndex];
		}
		
		public function cleanUp():void
		{
			clearAnimPrefabInstances();
			Starling.juggler.removeTweens(_machineTexture);			
			_tableView.removeChild(_machineTexture);
		}
		
		public function clearAnimPrefabInstances():void
		{
			for(var i:int=0; i<_animPrefabInstances.length; i++)
			{
				_tableView.removeChild(_animPrefabInstances[i], true);
				Starling.juggler.removeTweens(_animPrefabInstances[i]);
				_animPrefabInstances[i] = null;
			}
			
			_animPrefabInstances.splice(0, _animPrefabInstances.length);
		}
	}
}