package com.mangogames.views.mediators
{
	import com.creativebottle.starlingmvc.events.EventMap;
	import com.mangogames.managers.ConfigManager;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.lobby.LobbyScreenView;
	import com.mangogames.views.login.LoginScreenView;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.variables.RoomVariable;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	
	
	import starling.events.Event;
	

	public class LobbyScreenMediator extends AbstractBaseMediator
	{
		private var _eventMap:EventMap = new EventMap();
		
		[ViewAdded]
		public function viewAdded(view:LobbyScreenView):void
		{
			super.postConstruct(view);
			
			_eventMap.addMap(LobbyScreenView(view).moreBtn, Event.TRIGGERED, onMoreBtnClickHandler);
			_eventMap.addMap(LobbyScreenView(view).addChipsBtn, Event.TRIGGERED, onBuyChipsBtnClickHandler);
			_eventMap.addMap(LobbyScreenView(view).tablesBtn, Event.TRIGGERED,  onTablesClickHandler);
			
			ProxySignals.getInstance().joinRoomRequestSignal.add(onJoinRoomRequest);
		}
		
		private function onJoinRoomRequest(room:Room, isSpectator:Boolean, isMyTable:Boolean=false):void
		{
			var roomName:String	= room.name;
			var roomId:int		= room.id;
			
			var leaveTableVar:RoomVariable	= room.getVariable("isleavetable");
			var isLeaveTable:Boolean		= leaveTableVar ? leaveTableVar.getValue():false;
			
			if (roomName && roomName.length > 0)
			{
				if(room.groupId != "100") //for Pool
				{
					SFSInterface.getInstance().QuickJoin(roomName,ConfigManager.I.buyInAmount, isSpectator, isMyTable);
				}
				else
				{
					if (isMyTable && !isLeaveTable)
					{
						SFSInterface.getInstance().QuickJoin(roomName,ConfigManager.I.buyInAmount, isSpectator, isMyTable);
					}
					else
					{
						if(isSpectator)
							SFSInterface.getInstance().QuickJoin(roomName, 0, isSpectator);
						else
							validateBuyinAndSendReqToServer(room);
					}
				}
			}
			else
			{
				SFSInterface.getInstance().sendQuickPlayRequest(0, 0);
			}
		}
		
		private function validateBuyinAndSendReqToServer(room:Room):void
		{
			var balance:int;
			
			if(room.getVariable("RealOrFun").getIntValue() == 0)
				balance = SFSInterface.getInstance().userInfo.chips;
			else
				balance = SFSInterface.getInstance().userInfo.gold;
			
			var reqAmount:int		= room.getVariable("Bet").getIntValue();
			
			LobbyScreenView(_view).validateBuyIn(room, reqAmount * 80, balance);
		}
		
		private function onBuyChipsBtnClickHandler():void
		{
			navigateToURL(new URLRequest(Constants.TARGET_WEBSITE+ "/buyRealchips.html"), "_blank");
		}
		
		private function onTablesClickHandler():void
		{
			LobbyScreenView(_view).showJoinedTables();
		}
		
		
		private function onMoreBtnClickHandler():void
		{
			LobbyScreenView(_view).switchLobbySettings(onLogOut);
		}
		
		[ViewRemoved]
		public function viewRemoved(view:LobbyScreenView):void
		{	
			cleanup();
			
			_view = null;
			_eventMap.removeAllMappedEvents();
			
			//ProxySignals.getInstance().roomJoinResultSignal.remove(onRoomJoin);
			//ProxySignals.getInstance().updateuseraccountSignal.remove(onUserAccountUpdated);
		}
		
		
		private function onRoomJoin():void
		{
			//transitionView(GameView);
		}
		
		private function onLogOut():void
		{
			SFSInterface.getInstance().logOutRequest();
			ProxySignals.getInstance().logoutSignal.dispatch();
			transitionView(LoginScreenView);
		}
		
		private function onUserAccountUpdated(chips:int, gold:int):void
		{
		}
		
		
		override protected function onExit():void
		{
	
		}
	}
}