package com.mangogames.rummy.model.impl
{
	import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;

	public class ScratchCardEntryImpl implements SerializableSFSType
	{
		private var _win:Boolean;
		private var _desc:String;
		private var _id:int;
		private var _reward:int;
		
		public function ScratchCardEntryImpl()
		{
		}
		
		
		public function get reward():int
		{
			return _reward;
		}

		public function set reward(value:int):void
		{
			_reward = value;
		}

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}

		public function get desc():String
		{
			return _desc;
		}

		public function set desc(value:String):void
		{
			_desc = value;
		}

		public function get win():Boolean
		{
			return _win;
		}

		public function set win(value:Boolean):void
		{
			_win = value;
		}
	}
}