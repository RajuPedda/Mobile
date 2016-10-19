package com.mangogames.events
{
	import com.mangogames.views.game.tableview.CardView;
	
	import starling.events.Event;
	
	public class CardTouchedEvent extends Event
	{
		public static const CARD_TOUCHED:String = "cardTouched";
		
		public var touchedCard:CardView;
		public var phase:String;
		public var touchedOffsetX:int;
		public var touchedOffsetY:int;
		
		public function CardTouchedEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data);
		}
	}
}