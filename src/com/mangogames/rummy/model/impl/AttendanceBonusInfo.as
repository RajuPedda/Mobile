package com.mangogames.rummy.model.impl
{
	import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;

	public class AttendanceBonusInfo implements SerializableSFSType 
	{
		private var _chips:int;
		private var _gold:int;
		private var _item:String;
		private var _id:int;
		
		public function AttendanceBonusInfo()
		{
		}

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}

		public function get item():String
		{
			return _item;
		}

		public function set item(value:String):void
		{
			_item = value;
		}

		public function get gold():int
		{
			return _gold;
		}

		public function set gold(value:int):void
		{
			_gold = value;
		}

		public function get chips():int
		{
			return _chips;
		}

		public function set chips(value:int):void
		{
			_chips = value;
		}
	}
}