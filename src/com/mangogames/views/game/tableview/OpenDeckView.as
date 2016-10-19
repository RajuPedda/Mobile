package com.mangogames.views.game.tableview
{
	import com.mangogames.rummy.model.impl.CardImpl;
	
	import feathers.controls.Label;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	
	import utils.Ace2JakCard;
	import utils.ScaleUtils;
	
	public class OpenDeckView extends BaseTableItem
	{
		private var _dropHereBg:Quad;
		private var _tween:Tween;
		
		private var _table:TableView;
		
		public function OpenDeckView(table:TableView)
		{
			super();
			
			_table = table;
			
			_dropHereBg = new Quad(100, 100, 0x4a4137);
			_dropHereBg.visible	= false;
			ScaleUtils.applyPercentageScale(_dropHereBg, 12, 24);
			addChild(_dropHereBg);
			
			var label:Label	= new Label();
			//addChild(label);
			label.validate();
			label.text	= "Drop here";
			label.styleNameList.add("settings-label");
		//	label.x = (width-label.width)/2;
			//label.y	= (height-label.height)/2;
			//_dropHereBg = new Image(MangoAssetManager.I.getTexture("drop_here"));
			width = _dropHereBg.width;
			height = _dropHereBg.height;
		}
		
		override public function dispose():void
		{
			stopHighlight();
			_dropHereBg.removeFromParent(true);
			
			super.dispose();
		}
		
		public function highlight():void
		{
			stopHighlight();
			_dropHereBg.visible	= true;
			addChild(_dropHereBg)
			_dropHereBg.alpha = 0;
			
			_tween = new Tween(_dropHereBg, 1);
			_tween.repeatCount = 0;
			_tween.reverse = true;
			_tween.fadeTo(0.7);
			Starling.juggler.add(_tween);
		}
		
		public function stopHighlight():void
		{
			removeChild(_dropHereBg)
			
			if (!_tween)
				return;
			
			Starling.juggler.remove(_tween);
			_tween = null;
		}
		
		public function clear():void
		{
			var containsBg:Boolean = contains(_dropHereBg);
			if (containsBg)
				removeChild(_dropHereBg);
			
			removeChildren(0, -1, true);
			
//			if (containsBg)
//				addChild(_dropHereBg);
		}
		
		public function updateDeck():void
		{
			clear(); // first empty the area
			
			var openCard:CardImpl;
			var cards:Array	= _table.dealImpl.opendeck.card;
			
				openCard	= cards[cards.length-1];
			
			if (!openCard)
				return;
			trace("Rank  " + openCard.rank  +" Suit  "+ openCard.suit);
			
			var openCardFace:Ace2JakCard = openCard.ispaperjoker > 0
				? Ace2JakCard.manufacturePaperJoker(openCard.suit, openCard.rank, openCard.ispaperjoker)
				: Ace2JakCard.manufacture(openCard.suit, openCard.rank, _table.dealImpl.joker.card.rank == openCard.rank);
			openCardFace.toggleDropShadow(true);
			addChild(openCardFace);
			
			ScaleUtils.applyPercentageScale(openCardFace, 10, 21);
			//openCardFace.x += openCardFace.width/4;
			//openCardFace.y -= openCardFace.height/2;
		}
	}
}