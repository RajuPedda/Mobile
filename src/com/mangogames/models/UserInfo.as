package com.mangogames.models 
{
	public class UserInfo
	{
		private var _id:int;
		private var _name:String;
		private var _chips:int;
		private var _gold:int;
		private var _gender:int;
		private var _avatarId:String;
		
		public function UserInfo(id:int, name:String, chips:int, gold:int,gender:int, avatarId:String=""):void
		{
			_id 		= id;
			_name 		= name;
			_chips 		= chips;
			_gold 		= gold;
			_gender		= gender;
			_avatarId	= avatarId
		}
		
		public function get id():int { return _id; }
		public function get name():String { return _name; }
		public function get chips():int { return _chips; }
		public function set chips(value:int):void { _chips = value; }
		public function get gold():int { return _gold; }
		public function set gold(value:int):void { _gold = value; }
		public function get gender():int{return _gender;}
		public function set gender(value:int):void{_gender = value;}
		public function get avatarId():String{ return _avatarId; }
		public function set avatarId(value:String):void { _avatarId	= value; }

	}
}