package com.mangogames.events
{
	import starling.events.Event;

	public class NavigationEvent extends Event
	{
		public static const ADD_VIEW:String = "add_view";
		public static const CHANGE_VIEW:String = "change_view";
		public static const CHANGE_ROOM:String = "change_room";
		
		private var _result:Boolean;
		private var _dataObject:Object;
		private var _additionalInfo:Object;
		
		public function NavigationEvent(type:String, result:Boolean, dataObject:Object=null, bubbles:Boolean=false)
		{
			super(type, bubbles);
			_result = result;
			_dataObject = dataObject;
		}
		
		public function get additionalInfo():Object
		{
			return _additionalInfo;
		}

		public function set additionalInfo(value:Object):void
		{
			_additionalInfo = value;
		}

		public function get result():Boolean
		{ 
			return _result; 
		}
		
		public function get dataObject():Object
		{
			return _dataObject
		}
	}
}
