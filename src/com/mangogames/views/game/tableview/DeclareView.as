package com.mangogames.views.game.tableview
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.rummy.model.impl.CardImpl;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	
	import utils.Ace2JakCard;
	import utils.Fonts;
	import utils.ScaleUtils;
	
	public class DeclareView extends BaseTableItem
	{
		private var _container:Sprite;
		private var _tween:Tween;
		private var _cardImpl:CardImpl;
		
		public function DeclareView()
		{
			super();
			
			_container = new Sprite();
			_container.alpha = 0;
			addChild(_container);
			
			
			// bg
			var dropBg:Image = new Image(MangoAssetManager.I.getTexture("drop_here"));
			dropBg.width = 74;
			dropBg.height = 100;
			_container.addChild(dropBg);
			
			// text
			var message:String = "Drop card here to declare!";
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, Fonts.getInstance().smallFont, Color.YELLOW);
			var txtMessage:TextField = new TextField(dropBg.width - 10, 1, message, tf);
			txtMessage.autoSize = TextFieldAutoSize.VERTICAL;
			txtMessage.format.bold	= true;
			txtMessage.x = (width - txtMessage.width) / 2;
			txtMessage.y = 70;
			//_container.addChild(txtMessage);
		}
		
		override public function dispose():void
		{
			stopHighlight();
			
			super.dispose();
		}
		
		public function highlight():void
		{
			stopHighlight();
			
			_container.alpha = 0.3;
			
			_tween = new Tween(_container, 1);
			_tween.repeatCount = 0;
			_tween.reverse = true;
			_tween.fadeTo(1);
			Starling.juggler.add(_tween);
		}
		
		public function stopHighlight():void
		{
			_container.alpha = 0;
			
			if (!_tween)
				return;
			
			Starling.juggler.remove(_tween);
			_tween = null;
		}
		
		public function clear():void
		{
			stopHighlight();
			
			removeChild(_container);
			
			_cardImpl = null;
			
			removeChildren(0, -1, true);
			
			addChild(_container);
		}
		
		public function updateDeck(card:CardImpl, jokerRank:int):void
		{
			clear();
			
			_container.alpha = 1;
			
			if (!card)
				return;
			
			_cardImpl = card;
			
			var cardFace:Ace2JakCard = card.ispaperjoker > 0
				? Ace2JakCard.manufacturePaperJoker(card.suit, card.rank, card.ispaperjoker)
				: Ace2JakCard.manufacture(card.suit, card.rank, jokerRank == card.rank);
			cardFace.toggleDropShadow(true);
			addChild(cardFace);
			
			ScaleUtils.applyPercentageScale(cardFace, 10, 21);
			//cardFace.scaleX	= cardFace.scaleY	= 0.8;
			//cardFace.x = (_container.width - cardFace.width) / 2;
			//cardFace.y = (_container.height - cardFace.height) / 2;
		}
		
		public function get cardImpl():CardImpl { return _cardImpl; }
	}
}