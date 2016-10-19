package com.mangogames.views.lobby
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.signals.ProxySignals;
	import com.smartfoxserver.v2.entities.SFSRoom;
	
	import feathers.controls.List;
	import feathers.controls.Screen;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	
	import starling.display.Image;
	
	import utils.ScaleType;
	import utils.ScaleUtils;

	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class RoomCommonScreen extends Screen
	{
		private var _roomsList:Array;
		private var _totalListRooms:List;
		private var _stageW:int;
		private var _stageH:int;
		
		public function RoomCommonScreen()
		{
			super();
			ProxySignals.getInstance().roomAddedSignal.add(onRoomAdded);
		}
		
		private function onRoomAdded(sfsRoom:SFSRoom):void
		{
			_roomsList.push(sfsRoom);
			var collection:ListCollection	= new ListCollection(_roomsList);
			_totalListRooms.dataProvider	= collection;
		}
		
		public function setRoomList(value:Array):void
		{
			var len:int	= value.length;
			var sfsRoom:SFSRoom;
			
			for(var i:int=0; i<len; i++)
			{
				sfsRoom	= value[i];
				
				if(sfsRoom.userCount == 1)
					sfsRoom.properties.displayStatus	= 3; // Registering ( high priority )
				else if(sfsRoom.userCount == sfsRoom.maxUsers)
					sfsRoom.properties.displayStatus	= 0; // Closed (low Priority);
				else if(sfsRoom.userCount > 1)
					sfsRoom.properties.displayStatus	= 2; // Playing
				else
					sfsRoom.properties.displayStatus	= 1; // Open
			}
			reArrangeRoomsBasedOnPriority(value);
		}
		
		public function reArrangeRoomsBasedOnPriority(_rooms:Array, isRefresh:Boolean=false):void
		{
			/*if(isRefresh)
			{
				lstRooms.dataProvider	= null;
				setRoomList(value);
			}
			*/
			_rooms.sort(compareFunc, Array.NUMERIC);
			//_rooms.refresh();
			
			function compareFunc(a:Object, b:Object, fields:Array = null):int
			{
				var itemA:SFSRoom = SFSRoom(a);
				var itemB:SFSRoom = SFSRoom(b);
				
				
				var displayStatusA:int 	= itemA.properties.displayStatus; 
				var displayStatusB:int 	= itemB.properties.displayStatus; 
				var betAmountA:int 		= itemA.getVariable("Bet").getIntValue();
				var betAmountB:int 		= itemB.getVariable("Bet").getIntValue();
				
				if (displayStatusA > displayStatusB)
				{
					return -1;
				}
				else if (displayStatusA < displayStatusB)
				{
					return 1;
				}
				else
				{
					if (betAmountA < betAmountB)
						return -1;
					if (betAmountA > betAmountB)
						return 1;
				}
				
				return 0;
			}
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			setRoomList(_roomsList);
			
			var listCollection:ListCollection	= new ListCollection(_roomsList);
			_totalListRooms	= new List();
			ScaleUtils.applyPercentageScale(_totalListRooms, 95, 59);
			_totalListRooms.autoHideBackground = true;
			_totalListRooms.isSelectable	= true;
			_totalListRooms.hasElasticEdges	= false;
			_totalListRooms.revealScrollBars();
			
			var roomVariable:RoomRowValues	= new RoomRowValues();
			roomVariable.gameTypeLabel.text	= "Game Tpe";
			roomVariable.betAmountLabel.text= "Bet Amount";
			roomVariable.maxUsersLabel.text	= "Max Users";
			roomVariable.statusLabel.text	= "Status";
			roomVariable.playersCountLabel.text	= "Players Count"
			roomVariable.btnJoin.visible	= false;
			
			var base:Image	= MangoAssetManager.I.getImage("type_box", ScaleType.NONE);
			
			_totalListRooms.itemRendererFactory	= function ():IListItemRenderer
			{
				var renderer:RoomItemRenderer	= new RoomItemRenderer();
				renderer.padding	= Number(stageH/40);
				return renderer; 
			}
			
			_totalListRooms.dataProvider	= listCollection;
			_totalListRooms.x	= stageW/40;
			_totalListRooms.y	= stageH/24;
			roomVariable.y	= _totalListRooms.y;
			addChild(_totalListRooms);
			base.width	= _totalListRooms.width;
			base.x		= _totalListRooms.x;
			
			roomVariable.gameTypeLabel.x	+= Number(stageH/40);
			roomVariable.statusLabel.x		+= Number(stageH/30);
			roomVariable.gameTypeLabel.y	+= base.height/4;
			roomVariable.betAmountLabel.y	+= base.height/4;
			roomVariable.maxUsersLabel.y	+= base.height/4;
			roomVariable.statusLabel.y		+= base.height/4;
			roomVariable.playersCountLabel.y+= base.height/4;
			roomVariable.addChildAt(base, 0);
			addChild(roomVariable);
		}
		
		
		public function get roomsList():Array{	return _roomsList;}
		public function set roomsList(value:Array):void{_roomsList = value;}
		public function get stageW():int{return _stageW;}
		public function set stageW(value:int):void{_stageW = value;}
		public function get stageH():int{return _stageH;}
		public function set stageH(value:int):void{_stageH = value;}
		
	}
}