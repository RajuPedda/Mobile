package com.mangogames.views.game.tableview
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.rummy.model.impl.CardImpl;
	
	import feathers.controls.ScrollContainer;
	import feathers.layout.HorizontalLayout;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.Color;
	
	public class DiscardedCardsView extends Sprite
	{
		private var _tabsContainer:Sprite;
		private var _cardContainer:Sprite;
		private var _intialPosition:Number;
		private var _Width:int;
		private var _Height:int;
		private var _Bg:Image;
		
		public function DiscardedCardsView(Width:int, Height:int)
		{
			super();
			_Width	= Width;
			_Height	= Height;
	/*		var bgTexture:Texture	= MangoAssetManager.I.getTexture("discards_popup");
			var rect:Rectangle = new Rectangle( 10, 30, 60, 60 );
			var textures:Scale9Textures = new Scale9Textures( bgTexture, rect );
			
			var image:Scale9Image = new Scale9Image( textures, 1 );
			image.width = 470;
			image.height = 150;
			image.smoothing	= TextureSmoothing.NONE;
			this.addChild( image )*/
			
			_Bg = new Image(MangoAssetManager.I.getTexture("discards_popup"));
			_Bg.width	= Width/2 ;//470;
			_Bg.height	=  Height/3.3; ///150;
			addChild(_Bg); // width = 300, height = 200
			
			_tabsContainer = new Sprite();
			//_tabsContainer.y = 33;
			//_tabsContainer.x = 15;
			addChild(_tabsContainer);
			
			_cardContainer = new Sprite();
			_cardContainer.y = 33;
			addChild(_cardContainer);
			
			var headerTf:TextField	= new TextField(1, 1, "Discards");
			headerTf.autoSize		= TextFieldAutoSize.BOTH_DIRECTIONS;
			headerTf.x				= (_Bg.width-headerTf.width)/2;
			headerTf.y				= 8;
			headerTf.format.size	= 14;
			headerTf.format.color	= Color.WHITE;
			addChild(headerTf);
			
		/*	scaleX = 0.7;
			scaleY = 0.7;*/
			
			var btnClose:Button = new Button(MangoAssetManager.I.getTexture("close_btn"));
			addChild(btnClose);
			btnClose.x = this.width- btnClose.width-10; //435;
			btnClose.y = 5;
			btnClose.scaleX = btnClose.scaleY = 1.7;
			btnClose.addEventListener(Event.TRIGGERED, onClickClose);
		}
		
		private function onClickClose(event:Event):void
		{
			_intialPosition = this.x + width; 

			var tween:Tween = new Tween(this, 0.2, Transitions.EASE_IN_OUT);
			tween.scaleTo(0.1);
			tween.onUpdate = tween_update;
			tween.onComplete = tween_complete;
			//tween.onCompleteArgs = [popUp, dispose];
			Starling.juggler.add(tween);
		//	this.visible = false;	
		}
		
		private function tween_update():void
		{
			this.x = _intialPosition - this.width;
		}
		
		private function tween_complete():void
		{
			this.visible = false;	
			this.scaleX = 1//0.7;
			this.scaleY = 1//0.7;
			this.x = _intialPosition - this.width;
		}
		
		override public function dispose():void
		{
			reset();
			
			super.dispose();
		}
		
		public function reset():void
		{
			_tabsContainer.removeChildren(0, -1, true);
			_cardContainer.removeChildren(0, -1, true);
		}
		
		public function resetCardContainers():void
		{
			for (var i:int = 0; i < _cardContainer.numChildren; i++)
			{
				var container:ScrollContainer = _cardContainer.getChildAt(i) as ScrollContainer; 
				if (container)
					container.removeChildren(0, -1, true);
			}
		}
		
		public function addTabFor(playerName:String):void
		{
			if (!_tabsContainer.getChildByName(playerName))
			{
				// I am using playerName as the 'key' to find and manage
				// the buttons and card-containers. It is very important
				// here that you should handle this value very carefully!!
				
				var button:Button = new Button(MangoAssetManager.I.getTexture("footer_btn"), playerName);
				//button.width 	-= 10;
				//button.height 	-= 2;
				button.y		= _Bg.height - button.height -10;
				button.x		= button.width;
				button.name 	= playerName;
				button.textFormat.color	= Color.WHITE;
				button.textFormat.size     = 10;
				_tabsContainer.addChild(button);
				button.addEventListener(Event.TRIGGERED, function (event:Event):void
				{
					var button:Button = event.currentTarget as Button;
					if (button)
						focusTab(button.name);
				});
				
				var container:ScrollContainer = new ScrollContainer();
				container.width = _Width/2;  ///460;
				container.height = _Height/8 ///80;
				container.layout = new HorizontalLayout();
				HorizontalLayout(container.layout).gap = -30;
				container.y = 5;
				container.x	= 15;
				container.interactionMode = ScrollContainer.INTERACTION_MODE_TOUCH_AND_SCROLL_BARS;
				container.scrollBarDisplayMode = ScrollContainer.SCROLL_BAR_DISPLAY_MODE_FIXED;
				
				container.name = playerName;
				_cardContainer.addChild(container);
				
				rearrangeTabs();
				focusTab(playerName);
			}
		}
		
		public function removeTabForPlayer(playerName:String):void
		{
			// remove button
			for (var i:int = 0; i < _tabsContainer.numChildren; i++)
			{
				var button:Button = Button(_tabsContainer.getChildAt(i));
				if (button.name == playerName)
				{
					_tabsContainer.removeChildAt(i, true);
					break;
				}
			}
			
			// remove container
			for (i = 0; i < _tabsContainer.numChildren; i++)
			{
				var container:Sprite = Sprite(_cardContainer.getChildAt(i));
				if (container.name == playerName)
				{
					_cardContainer.removeChildAt(i, true);
					break;
				}
			}
			
			rearrangeTabs();
		}
		
		public function addDiscardedCard(cardImpl:CardImpl, playerName:String, jokerRank:int):void
		{
			if (cardImpl == null || playerName == null || playerName.length == 0)
				return;
			
			// first create a button and container if not present
			addTabFor(playerName);
			
			var card:CardView = new CardView();
			card.initCard(cardImpl, cardImpl.rank == jokerRank);
			card.touchable = false;
			card.scaleX = 0.6;
			card.scaleY = 0.5;
			
			var container:ScrollContainer = ScrollContainer(_cardContainer.getChildByName(playerName));
			container.addChild(card);
			//rearrangeCards(container);
			container.scrollToPosition(container.maxHorizontalScrollPosition + 50, 0, 0.2);
		}
		
		public function removeDiscardedCard(card:CardImpl, playerName:String):void
		{
			if (card == null || playerName == null || playerName.length == 0)
				return;
			
			// using playerName to find container
			var container:Sprite = Sprite(_cardContainer.getChildByName(playerName));
			if (!container)
				return;
			
			for (var i:int = container.numChildren - 1; i >= 0; i--) // go reverse
			{
				var oldCard:CardView = container.getChildAt(i) as CardView;
				if (oldCard && (oldCard.isPaperJoker == card.ispaperjoker) &&
					(oldCard.rank == card.rank && oldCard.suit == card.suit))
				{
					container.removeChildAt(i, true);
					return;
				}
			}
		}
		
		public function focusTab(playerName:String):void
		{
			// focus tab
			for (var i:int = 0; i < _tabsContainer.numChildren; i++)
			{
				var button:Button = Button(_tabsContainer.getChildAt(i));
				button.alpha = button.name == playerName ? 1 : 0.7;
			}
			
			// now focus container
			for (i = 0; i < _tabsContainer.numChildren; i++)
			{
				var container:Sprite = Sprite(_cardContainer.getChildAt(i));
				container.visible = container.name == playerName ? true : false;
			}
		}
		
		private function rearrangeTabs():void
		{
			var xPos:int = 0;
			for (var i:int = 0; i < _tabsContainer.numChildren; i++)
			{
				_tabsContainer.getChildAt(i).x = xPos;
				xPos += 75;
			}
		}
		
		private function rearrangeCards(container:Sprite):void
		{
			var xPos:int = 0;
			for (var i:int = 0; i < container.numChildren; i++)
			{
				container.getChildAt(i).x = xPos;
				xPos += 30;
			}
		}
	}
}