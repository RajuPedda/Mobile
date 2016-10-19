package com.mangogames.events
{
	import starling.events.Event;
	
	public class HandCardIndicatorTouchedEvent extends Event
	{
		public static const HAND_CARDS_TOUCHED:String = "handCardIndicatorTouchedEvent";
		
		public function HandCardIndicatorTouchedEvent()
		{
			super(HAND_CARDS_TOUCHED, false, null);
		}
	}
}