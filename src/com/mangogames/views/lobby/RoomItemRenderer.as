package com.mangogames.views.lobby
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.SFSRoom;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.variables.RoomVariable;
	import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
	
	import feathers.controls.Label;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.utils.touch.TapToSelect;
	import feathers.utils.touch.TapToTrigger;
	
	import starling.events.Event;
	
	import utils.ScaleType;

	public class RoomItemRenderer extends LayoutGroupListItemRenderer implements IListItemRenderer
	{
		private var _select:TapToSelect;
		private var _trigger:TapToTrigger;
		
		public function RoomItemRenderer()
		{
			super();
			this.addEventListener(Event.CHANGE, onDataChange);
		}
		
		private var _label:Label;
		private var _roomValues:RoomRowValues;
		
		override protected function initialize():void
		{
			super.initialize();
			_trigger	= new TapToTrigger(this);
			_select	= new TapToSelect(this);
			if(!this._label)
			{
				this._label = new Label();
				//this.addChild(this._label);
			}
			_roomValues	= new RoomRowValues();
			addChild(_roomValues);
		}
		
		
		override protected function commitData():void
		{
			super.commitData();
			this.backgroundSkin	= MangoAssetManager.I.getImage("type_box", ScaleType.NONE);
			if(this._data)
			{
				var type:String;
				var name:String;
				switch(_data.groupId)
				{
					case "100": type = "PR-Rummy"
						break;
					case "101": type = "101 Pool"
						break;
					case "102":
						name	= _data.name.substring(3,4);
						type = name=="2"?"Best of 2":"Best of 3"
						break;
					case "201": type = "201 Pool"
						break;
				}
				this._roomValues.gameTypeLabel.text	= type;
				this._roomValues.betAmountLabel.text= "" +Number(_data.getVariable("Bet").getIntValue() / 100);
				this._roomValues.maxUsersLabel.text	= ""+_data.maxUsers;
				this._roomValues.statusLabel.text	= getRoomStatus();
				this._roomValues.playersCountLabel.text	= getUserCount(data as SFSRoom) +"/" +_data.maxUsers;
				this._roomValues.btnJoin.label		= "Join";
				this._roomValues.btnJoin.addEventListener(Event.TRIGGERED, onJoinBtnClickHandler);
			}
			else
			{
				this._label.text = null;
				this._roomValues.gameTypeLabel.text	= "";
				this._roomValues.betAmountLabel.text= "" ;
				this._roomValues.maxUsersLabel.text	= "";
				this._roomValues.statusLabel.text	= "";
				this._roomValues.playersCountLabel.text	= "";
			}
		}
		
		private function onDataChange():void
		{
			
		}
		
		private function getRoomStatus():String
		{
			var label:String;
			
			var room:Room 					= data as SFSRoom;
			var roomUserCount:int 			= getUserCount(room);
			var roomVar:RoomVariable 		= data.getVariable("Status");
			var roomClosedVar:RoomVariable	= data.getVariable("roomclosed");
			var isRoomClosed:Boolean		= roomClosedVar.getBoolValue();
			var styleName:Object			= this._roomValues.btnJoin.styleName;
			
			switch (true)
			{
				case isRoomClosed && (data.groupId != 100):
					if(styleName != "watchStyle" && !getIsMyTableRoom(room))
						//changeBtnSkin("Watch");
						label = "Closed";
					break;
				
				case roomVar && roomVar.getIntValue() == 3:
					if (data.groupId == 100)
					{
						if ((roomUserCount == data.maxUsers))
						{
							label = "Closed";
						}
						else
						{
							label = roomUserCount == 1? "Registering":"Playing";
						}
					}
					else
					{
						label = "Closed";
					}
					break;
				
				case data.userCount > 0 && roomUserCount == data.maxUsers:
					label = "Closed";
					break;
				
				case data.userCount > 0:
					label = "Registering";
					break;
				
				case data.maxUsers > 0 && data.userCount == 0:
					if(roomUserCount > data.userCount)
					{
						label = "Registering";
					}
					else
					{
						label = "Open";
					}
					
					break;
				default:
					label = "N/A";
					break;
			}
			
			
			return label;
		}
		
		private function isWatch(room:SFSRoom):Boolean
		{
			var watch:Boolean	= false;
			if(room.maxUsers == room.userCount)
			{
				watch	= true;
			}
			else if(room.groupId != "100")
			{
				var roomClosedVar:RoomVariable	= data.getVariable("roomclosed");
				var isRoomClosed:Boolean		= roomClosedVar.getBoolValue();
				if(isRoomClosed)
					watch	= true;
			}
			return watch;
		}
		
		private function onJoinBtnClickHandler():void
		{
			var joinBtnClickHandler:JoinBtnClickHandler	= new JoinBtnClickHandler(data as SFSRoom);
		}
		
		private function onClickOkForPool():void
		{
			if(data == null)
				return;
			var room:Room = data as SFSRoom;
			var roomVar:RoomVariable = data.getVariable("Status");
			
			if (getIsMyTableRoom(room))
			{
				ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room, false, true);
			}
			else
			{
				if (roomVar && roomVar.getIntValue() == 3)
					ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room, true);
				else
				{
					var roomClosedVar:RoomVariable	= room.getVariable("roomclosed");
					var isRoomClosed:Boolean		= roomClosedVar.getBoolValue();
					if(isRoomClosed)
					{
						ProxySignals.getInstance().notifyRoomFullSignal.dispatch();
					}
					else
					{
						ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room);
					}
				}
				
			}
		}
		
		private function getIsMyTableRoom(sfsRoom:Room):Boolean
		{
			var roomVar:RoomVariable = sfsRoom.getVariable("isleavetableArray");
			if(!roomVar)
				return true;
			
			var playersList:SFSArray	= SFSArray(roomVar.getSFSArrayValue());
			var len:int				= playersList?playersList.size():0;
			var currentUserId:Number= SFSInterface.getInstance().userInfo.id;
			var playerObj:ISFSObject;
			var isLeaveTable:Boolean;
			var playerId:Number;
			
			for( var i:int=0; i<len; i++)
			{
				playerObj	= playersList.getSFSObject(i);
				playerId	= playerObj.getLong("playerid");
				if(currentUserId == playerId)
				{
					isLeaveTable	= playerObj.getBool("isleavetable");
					if(!isLeaveTable)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		private function getUserCount(sfsRoom:Room):int
		{
			var idNamePairs:SFSObject = SFSRoomVariable(data.getVariable("Players")).getValue();
			var ids:Array = idNamePairs.getKeys();
			
			if(isAnyOneLeftTheTable(sfsRoom))
			{
				var len:int	= sfsRoom.playerList.length;
				if(len >0)
					return sfsRoom.userCount;
			}
			if (ids)
				return ids.length;
				
			else
				return 0;
		}
		
		private function isAnyOneLeftTheTable(sfsRoom:Room):Boolean
		{
			var roomVar:RoomVariable = sfsRoom.getVariable("isleavetableArray");
			if(!roomVar)
				return false;
			
			var playersList:SFSArray	= SFSArray(roomVar.getSFSArrayValue());
			var len:int				= playersList?playersList.size():0;
			var playerObj:ISFSObject;
			var isLeaveTable:Boolean;
			var playerId:Number;
			
			for( var i:int=0; i<len; i++)
			{
				playerObj	= playersList.getSFSObject(i);
				playerId	= playerObj.getLong("playerid");
				isLeaveTable	= playerObj.getBool("isleavetable");
				if(isLeaveTable && playerId>0)
				{
					return true;
				}
			}
			return false;
		}
		
		protected var _padding:Number = 0;
		
		public function get padding():Number
		{
			return this._padding;
		}
		
		public function set padding(value:Number):void
		{
			if(this._padding == value)
			{
				return;
			}
			this._padding = value;
			this.invalidate(INVALIDATION_FLAG_LAYOUT);
		}
		
		override protected function draw():void
		{
			super.draw();
			var dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			this.autoSizeIfNeeded();
			this.layoutChildren();
		}
		
		protected function autoSizeIfNeeded():Boolean
		{
			var needsWidth:Boolean = isNaN(this.explicitWidth);
			var needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			
			this._label.width = this.explicitWidth - 2 * this._padding;
			this._label.height = this.explicitHeight - 2 * this._padding;
			this._label.validate();
			
			this._roomValues.width = this.explicitWidth - 2 * this._padding;
			this._roomValues.height = this.explicitHeight - 2 * this._padding;
			this._roomValues.gameTypeLabel.validate();
			
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = this._roomValues.gameTypeLabel.width + 2 * this._padding;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = this._roomValues.gameTypeLabel.height + 2 * this._padding;
			}
			
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function layoutChildren():void
		{
			this._label.x = this._padding;
			this._label.y = this._padding;
			this._label.width = this.actualWidth - 2 * this._padding;
			this._label.height = this.actualHeight - 2 * this._padding;
			
			_roomValues.x	= this._padding;
			_roomValues.y	= this._padding;
			_roomValues.gameTypeLabel.width 	= this.actualWidth - 2 * this._padding;
			_roomValues.gameTypeLabel.height 	= this.actualHeight - 2 * this._padding;
			
			this.backgroundSkin.height			= this.actualHeight;
		}
	}
}