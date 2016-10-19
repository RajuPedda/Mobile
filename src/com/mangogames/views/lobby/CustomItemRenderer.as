package com.mangogames.views.lobby
{
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.game.GameStatsView;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.SFSRoom;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.variables.RoomVariable;
	import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.utils.touch.TapToSelect;
	import feathers.utils.touch.TapToTrigger;
	
	import starling.events.Event;

	/**
	 * 
	 * @author Raju Pedda.M
	 * 
	 */	
	public class CustomItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private var _label:Label;
		private var _roomValues:RoomRowValues;
		private var _select:TapToSelect;
		private var _trigger:TapToTrigger;
		
		public function CustomItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			if(!this._label)
			{
				this._label = new Label();
				//this.addChild(this._label);
			}
			_trigger	= new TapToTrigger(this);
			_select		= new TapToSelect(this);
				_roomValues	= new RoomRowValues();
				addChild(_roomValues);
		}
		
		protected var _owner:List;
		
		public function get owner():List
		{
			return this._owner;
		}
		
		public function set owner(value:List):void
		{
			if(this._owner == value)
			{
				return;
			}
			this._owner = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _data:Object;
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _factoryID:String;
		
		public function get factoryID():String
		{
			return this._factoryID;
		}
		
		public function set factoryID(value:String):void
		{
			this._factoryID = value;
		}
		
		protected var _index:int = -1;
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			if(this._index == value)
			{
				return;
			}
			this._index = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _isSelected:Boolean;
		
		public function get isSelected():Boolean
		{
			return this._isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			if(this._isSelected == value)
			{
				return;
			}
			this._isSelected = value;
			this.invalidate(INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		
		protected function commitData():void
		{
			if(this._data)
			{
				this._label.text = this._data.name;
				var type:String;
				var variables:Array	= SFSRoom(_data).getVariables();
				
				switch(_data.groupId)
				{
					case "100": type = "PR-Rummy"
						break;
					case "101": type = "101 Pool"
						break;
					case "102": type = "Best of N"
						break;
					case "201": type = "201 Pool"
						break;
				}
				this._roomValues.gameTypeLabel.text	= type;
				this._roomValues.betAmountLabel.text= "" +Number(_data.getVariable("Bet").getIntValue() / 100);
				this._roomValues.maxUsersLabel.text	= ""+_data.maxUsers;
				this._roomValues.statusLabel.text	= "Open";
				this._roomValues.playersCountLabel.text	= _data.userCount +"/" +_data.maxUsers;
				this._roomValues.btnJoin.label		= "Join";
				this._roomValues.btnJoin.addEventListener(Event.TRIGGERED, onJoinBtnClickHandler);
			}
			else
			{
				this._label.text = null;
			}
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
			_select.tapToDeselect	= true;
			var room:Room = data as SFSRoom;
			
			var realOrFun:int = room.getVariable("RealOrFun").getIntValue();
			
			var availableAmount:int = realOrFun == 0 ? SFSInterface.getInstance().userInfo.chips : SFSInterface.getInstance().userInfo.gold;
			var reqAmount:int		= room.getVariable("Bet").getIntValue();
			var isMyTable:Boolean	= getIsMyTableRoom(room);
			var watch:Boolean		= isWatch(data as SFSRoom);
			if (reqAmount > availableAmount && !isMyTable && !watch)
			{
				ProxySignals.getInstance().admmsgSignal.dispatch(0, "no.chips", "");
			}
			else
			{
				if (getIsMyTableRoom(room))
				{
					ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room, false, true);
				}
				else
				{
					if(room.groupId != "100")
					{
						var roomVar:RoomVariable 		= data.getVariable("Status");
						var roomClosedVar:RoomVariable	= data.getVariable("roomclosed");
						var isRoomClosed:Boolean		= roomClosedVar.getBoolValue();
						var roomUserCount:int 			= getUserCount(room);
						
						if(isRoomClosed || (roomUserCount == data.maxUsers))
						{
							onClickOkForPool();
						}
						else
						{
							var questionString:String = "Do you want to join " + (realOrFun == 0 ? "play" : "real") + " chips | ";
							var gameName:String = GameStatsView.getRoomNameStringByGroupId(SFSRoom(data)) + " | ";
							var maxPlayers:String = data.maxUsers + " Players | ";
							var betTable:String = Number(data.getVariable("Bet").getIntValue() / 100).toFixed(2).toString()+" Bet Table?"
							
							ProxySignals.getInstance().confirmationMsgSignal.dispatch(questionString + gameName + maxPlayers + betTable ,onClickOkForPool);
						}
					}
					else
					{
						roomUserCount	= getUserCount(room);
						if(room.maxUsers == room.userCount)
							ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room, true);	
						else
						{
							/*if(room.maxUsers == getPlayersLen())
							ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room, true);	
							else*/
							if(room.maxUsers == roomUserCount)
								ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room, true);
							else
								ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room, false);	
						}
					}
				}
			}
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
				newWidth = this._label.width + 2 * this._padding;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = this._label.height + 2 * this._padding;
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
		}
	}
}