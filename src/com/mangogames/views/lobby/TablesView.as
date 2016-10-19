package com.mangogames.views.lobby
{
	import com.smartfoxserver.v2.entities.SFSRoom;
	
	import feathers.controls.Button;
	
	import starling.display.Sprite;
	import starling.events.Event;

	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class TablesView extends Sprite
	{
		public function TablesView(myJoinedTables:Array, containerW:int)
		{
			super();
			_myJoinedTables	= myJoinedTables;
			init(containerW);
		}
		
		private var _myJoinedTables:Array;
		
		private function init(containerW:int):void
		{
			var table1Btn:Button	= new Button();
			//table1Btn.width	= containerW;
			addChild(table1Btn);
			table1Btn.validate();
			table1Btn.label			= _myJoinedTables.length>0?getRoomName(_myJoinedTables[0]):"Table 1";
			table1Btn.y				= table1Btn.height*-1;
			table1Btn.addEventListener(Event.TRIGGERED, onTable1BtnClickHandler);
			
			/*var table2Btn:Button	= new Button();
			table2Btn.width	= containerW;
			table2Btn.label			= _myJoinedTables.length>1?getRoomName(_myJoinedTables[1]):"Table 2";
			table2Btn.y				= table1Btn.height*-2.1;
			addChild(table2Btn);
			table2Btn.addEventListener(Event.TRIGGERED, onTable2BtnClickHandler);*/
		}
		
		private function getRoomName(data:SFSRoom):String
		{
			var roomType:String;
			switch(data.groupId)
			{
				case "100": roomType = "PR-Rummy"
					break;
				case "101": roomType = "101 Pool"
					break;
				case "102": roomType = "Best of N"
					break;
				case "201": roomType = "201 Pool"
					break;
			}
			return roomType;
		}
		
		private function onTable1BtnClickHandler(event:Event):void
		{
			var joinBtnClickHandler:JoinBtnClickHandler	= new JoinBtnClickHandler(_myJoinedTables[0] as SFSRoom);
		}
		
		private function onTable2BtnClickHandler(event:Event):void
		{
			if(_myJoinedTables.length>1)	new JoinBtnClickHandler(_myJoinedTables[1] as SFSRoom);
		}
		
	}
}