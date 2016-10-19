package com.mangogames.rummy.model.impl
{
	import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;

	public class ScratchCardInfo implements SerializableSFSType
	{
		private var _scratchCardInfoList:Array = new Array();
		private var _scratchCardInfo:Array;
		
		public function ScratchCardInfo()
		{
		}

		public function get scratchCardInfo():Array
		{
			return _scratchCardInfo;
		}

		public function set scratchCardInfo(value:Array):void
		{
			_scratchCardInfo = value;
		}

		public function get scratchCardInfoList():Array
		{
			return _scratchCardInfoList;
		}

		public function set scratchCardInfoList(value:Array):void
		{
			_scratchCardInfoList = value;
		}
	}
}