package utils
{
	import com.mangogames.managers.MangoAssetManager;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.filters.DropShadowFilter;
	import starling.filters.GlowFilter;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	public class Ace2JakCard extends Sprite
	{
		private var _imgCard:Image;
		private var _suit:int;
		private var _rank:int;
		private var _showDropShadow:Boolean;
		private var _cardName:String;
		
		public function Ace2JakCard()
		{
			super();
		}
		
		override public function dispose():void
		{
			_imgCard.filter = null;
			_imgCard.removeFromParent(true);
			
			super.dispose();
		}
		
		public function highlight():void
		{
			var glowFilter:GlowFilter	= new GlowFilter();
			glowFilter.color	= Color.YELLOW;
			glowFilter.blur		= 2;
			_imgCard.filter 	= glowFilter;//BlurFilter.//createGlow();
		}
		
		public function stopHighlight():void
		{
			toggleDropShadow(_showDropShadow);
		}
		
		public function toggleDropShadow(value:Boolean):void
		{
			var dropShow:DropShadowFilter	= new DropShadowFilter();
			dropShow.color	= Color.BLACK;
			dropShow.blur	= 2;
			_imgCard.filter = _showDropShadow ? dropShow : null;
		}
		
		public function get cardName():String { return _cardName; }
		public function get rank():int { return _rank; }
		public function get suit():int { return _suit; }
		
		public static function manufacture(suit:int, rank:int, isJoker:Boolean, isFromScoreBoard:Boolean=false):Ace2JakCard
		{
			var cardName:String = "Back"; // starts with card back
			if (suit != -1)
			{
				// build-up the name of the texture to get
				var suitName:String = "";
				switch (suit)
				{
					case 0: suitName = "Club"	; break;
					case 1: suitName = "Diamond"; break;
					case 2: suitName = "Hearts"	; break;
					case 3: suitName = "Spades"	; break;
				}
				
				// add the rank
				var rankStr:String = "";
				switch (rank)
				{
					case 0:  rankStr = "A"; break;
					case 10: rankStr = "J"; break;
					case 11: rankStr = "Q"; break;
					case 12: rankStr = "K"; break;
					case 9: rankStr = "10"; break;
					case 13: rankStr = "A"; break; // only for highest card checking on match start
					default: rankStr = "0" + (rank + 1).toString(); break; // prefixing '0'
				}
				
				// final name
				cardName = suitName + "-" + rankStr;
			}
			
			// finally make a card
			var texCardBg:Texture = MangoAssetManager.I.getTexture(cardName);
			var imgCard:Image = new Image(texCardBg);
			
			// prepare the card
			var card:Ace2JakCard = new Ace2JakCard();
			card._suit = suit;
			card._rank = rank;
			card._imgCard = imgCard;
			card._cardName = cardName;
			card.addChild(card._imgCard);
			
			// if it is joker, then add joker logo
			if (isJoker)
			{
				var texJokerLogo:Texture = MangoAssetManager.I.getTexture("joker_logo");
				var imgJokerLogo:Image = new Image(texJokerLogo);
				card.addChild(imgJokerLogo);
				imgJokerLogo.x = 5;
				imgJokerLogo.y = imgCard.height - imgJokerLogo.height-6;
			}
			if(isFromScoreBoard)
				ScaleUtils.applyPercentageScale(card, 5, 10);
			else
				ScaleUtils.applyPercentageScale(card, 11, 24);
			
			return card;
		}
		
		public static function manufacturePaperJoker(suit:int, rank:int, colorFlag:int, isFromScoreBoard:Boolean=false):Ace2JakCard
		{
			// if paper joker colorflag is set then use it
			// color flag: 1 - red, 2 - black, 0 - not paper joker
			// otherwwise randomly select either red or black paper joker
			var cardName:String = "";
			switch (colorFlag)
			{
				case 1: cardName = "Joker-Red"; break;
				case 2: cardName = "Joker-Black"; break;
				default: throw new Error("Invalid paper joker color flag!"); break;
			}
			
			var card:Ace2JakCard = new Ace2JakCard();
			card._suit = suit;
			card._rank = rank;
			card._imgCard = new Image(MangoAssetManager.I.getTexture(cardName));
			card._cardName = cardName;
			card.addChild(card._imgCard);
			if(isFromScoreBoard)
				ScaleUtils.applyPercentageScale(card, 5, 10);
			else
				ScaleUtils.applyPercentageScale(card, 11, 24);
			return card;
		}
		
		public static function manufactureCardBack():Ace2JakCard
		{
			return manufacture(-1, -1, false);
		}
		
		public static function manufactureClosedDeck():Ace2JakCard
		{
			var card:Ace2JakCard = new Ace2JakCard();
			card._suit = -1;
			card._rank = -1;
			card._imgCard = new Image(MangoAssetManager.I.getTexture("closed_deck"));
			ScaleUtils.applyPercentageScale(card._imgCard, 10, 21);
			card.addChild(card._imgCard);
			card._cardName = "closed_deck";
			return card;
		}
		
		// util
		public static function getCardName(suit:int, rank:int):String
		{
			// build-up the name of the texture to get
			var suitName:String = "";
			switch (suit)
			{
				case 0: suitName = "Club"	; break;
				case 1: suitName = "Diamond"; break;
				case 2: suitName = "Hearts"	; break;
				case 3: suitName = "Spades"	; break;
			}
			
			// add the rank
			var rankStr:String = "";
			switch (rank)
			{
				case 0:  rankStr = "Ace"; break;
				case 10: rankStr = "Jack"; break;
				case 11: rankStr = "Queen"; break;
				case 12: rankStr = "King"; break;
				default: rankStr = (rank + 1).toString(); break;
			}
			
			// final name
			var cardName:String = suitName + " " + rankStr;
			return cardName;
		}
	}
}