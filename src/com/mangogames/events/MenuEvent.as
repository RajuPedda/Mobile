package com.mangogames.events
{
	import starling.events.Event;

	public class MenuEvent extends Event
	{
		private var _userData:Object;
		
		public static const GET_DATA:String = "getData";
		public static const ADD_CONTROL_PANEL:String = "addControlPanel";
		public static const REMOVE_CONTROL_PANEL:String = "removeControlPanel";
		public static const BONUS_COLLECTED:String = "bonuscollected";
		public static const CARDS_DEAL_COMPLETE:String = "cardsdealcomplete";
		public static const CHAT_SENT:String = "chatsent";
		public static const BUDDY_LIST_CLOSED:String = "buddylistclosed";
		public static const BUDDY_ITEM_SELECTED:String = "buddyitemselected";
		public static const JOIN_BUDDY:String = "joinbuddy";
		public static const BUDDY_LIST_OPENED:String = "buddylistopened";
		public static const LIST_ITEM_DELETED:String = "listitemdeleted";
		public static const INVITE_ACCEPTED:String = "inviteaccepted";
		public static const ROOM_ITEM_SELECTED:String = "roomitemselected";

		
		public function MenuEvent(type:String, userData:Object= null, bubbles:Boolean=false)
		{
			super(type, bubbles);
			
			_userData = userData;
			
			if(_userData != null)
			{
				trace("USER DATA " + _userData.type);
			}
		}
				
		public function get userData():Object
		{
			return _userData;
		}

		public function set userData(value:Object):void
		{
			_userData = value;
		}

	}
}