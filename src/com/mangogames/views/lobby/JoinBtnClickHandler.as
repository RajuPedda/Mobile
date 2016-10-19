package com.mangogames.views.lobby
{
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.game.GameStatsView;
	import com.mangogames.views.popup.ConfirmationPopup;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.SFSRoom;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.variables.RoomVariable;
	import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
	
	import feathers.core.PopUpManager;

	public class JoinBtnClickHandler
	{
		public function JoinBtnClickHandler(data:SFSRoom)
		{
			_data	= data;
			init();	
		}
		private var _data:SFSRoom;
		private var _confirmationPopupForPool:ConfirmationPopup;
		
		private function init():void
		{
			if(_data == null)
				return;
			
			var room:Room = _data as SFSRoom;
			
			var realOrFun:int = room.getVariable("RealOrFun").getIntValue();
			
			var availableAmount:int = realOrFun == 0 ? SFSInterface.getInstance().userInfo.chips : SFSInterface.getInstance().userInfo.gold;
			var reqAmount:int		= room.getVariable("Bet").getIntValue();
			var isMyTable:Boolean	= getIsMyTableRoom(room);
			var watch:Boolean		= isWatch(_data as SFSRoom);
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
						var roomVar:RoomVariable 		= _data.getVariable("Status");
						var roomClosedVar:RoomVariable	= _data.getVariable("roomclosed");
						var isRoomClosed:Boolean		= roomClosedVar.getBoolValue();
						var roomUserCount:int 			= getUserCount(room);
						
						if(isRoomClosed || (roomUserCount == _data.maxUsers))
						{
							onClickOkForPool();
						}
						else
						{
							/*var questionString:String = "Do you want to join " + (realOrFun == 0 ? "play" : "real") + " chips | ";
							var gameName:String = GameStatsView.getRoomNameStringByGroupId(SFSRoom(_data)) + " | ";
							var maxPlayers:String = _data.maxUsers + " Players | ";
							var betTable:String = Number(_data.getVariable("Bet").getIntValue() / 100).toFixed(2).toString()+" Bet Table?"
							
							ProxySignals.getInstance().confirmationMsgSignal.dispatch(questionString + gameName + maxPlayers + betTable ,onClickOkForPool);*/
							showConfirmationForPool(realOrFun);
							
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
		
		private function showConfirmationForPool(realOrFun:int):void
		{
			var questionString:String = "Do you want to join " + (realOrFun == 0 ? "play" : "real") + " chips | ";
			var gameName:String = GameStatsView.getRoomNameStringByGroupId(SFSRoom(_data)) + " | ";
			var maxPlayers:String = _data.maxUsers + " Players | ";
			var betTable:String = Number(_data.getVariable("Bet").getIntValue() / 100).toFixed(2).toString()+" Bet Table?";
			
			_confirmationPopupForPool	= new ConfirmationPopup("JOIN", questionString + gameName + maxPlayers + betTable, onClickOkForPool, onCancelClickHandler);
			PopUpManager.addPopUp(_confirmationPopupForPool);
		}
		
		private function onCancelClickHandler():void
		{
			
		}
		
		private function onClickOkForPool():void
		{
			if(_data == null)
				return;
			var room:Room = _data as SFSRoom;
			var roomVar:RoomVariable = _data.getVariable("Status");
			
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
						ProxySignals.getInstance().joinRoomRequestSignal.dispatch(room, false);
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
			var idNamePairs:SFSObject = SFSRoomVariable(_data.getVariable("Players")).getValue();
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
		
		private function isWatch(room:SFSRoom):Boolean
		{
			var watch:Boolean	= false;
			if(room.maxUsers == room.userCount)
			{
				watch	= true;
			}
			else if(room.groupId != "100")
			{
				var roomClosedVar:RoomVariable	= _data.getVariable("roomclosed");
				var isRoomClosed:Boolean		= roomClosedVar.getBoolValue();
				if(isRoomClosed)
					watch	= true;
			}
			return watch;
		}
	}
}