package com.mangogames.services
{
	import com.mangogames.models.UserInfo;
	import com.mangogames.rummy.model.impl.AttendanceBonusInfo;
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.util.GameUtil;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.game.GameStatsView;
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.SFSRoom;
	import com.smartfoxserver.v2.entities.SFSUser;
	import com.smartfoxserver.v2.entities.User;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.variables.RoomVariable;
	import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
	import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
	import com.smartfoxserver.v2.logging.LogLevel;
	import com.smartfoxserver.v2.logging.LoggerEvent;
	import com.smartfoxserver.v2.requests.ExtensionRequest;
	import com.smartfoxserver.v2.requests.JoinRoomRequest;
	import com.smartfoxserver.v2.requests.LeaveRoomRequest;
	import com.smartfoxserver.v2.requests.LoginRequest;
	import com.smartfoxserver.v2.requests.LogoutRequest;
	import com.smartfoxserver.v2.requests.PublicMessageRequest;
	import com.smartfoxserver.v2.requests.SetRoomVariablesRequest;
	import com.smartfoxserver.v2.requests.SetUserVariablesRequest;
	import com.smartfoxserver.v2.util.ConfigData;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import feathers.core.PopUpManager;
	
	import logger.Logger;
	
	import starling.core.Starling;
	import starling.display.Sprite;

	public class SFSInterface
	{
		// --- SINGLETON ---
		private static var _allowInstance:Boolean;
		private static var _instance:SFSInterface;
		
		public static function getInstance():SFSInterface
		{
			if (!_instance)
			{
				_allowInstance = true;
				_instance = new SFSInterface();
				_allowInstance = false;
			}
			return _instance;
		}
		// --- END SINGLETON ---
		
		private var _sfs:SmartFox;
		private var _sfsTimer:Timer;
		private var _userInfo:UserInfo;
		
		private var _mainStage:Sprite;
		private var _gameRooms:Vector.<GameRoom>;
		private var _focusedRoom:GameRoom;
		public var _isLoggedIn:Boolean;
		public var leaveTableCount:int;
		
		private var _pointRoomList:Vector.<SFSRoom>;
		private var _bestOfNList:Vector.<SFSRoom>;
		private var _pool101RummyList:Vector.<SFSRoom>;
		private var _pool201RummyList:Vector.<SFSRoom>;
		private var _isMiddleJoin:Boolean;
		
		private var _playersNames:Dictionary;
		
		public function SFSInterface()
		{
			if(!_allowInstance)
				throw new Error("Cannot create instance of singleton class LocalStorag, use getInstance() instead");
			
			_sfs = new SmartFox();
			registerLoggerEvents(_sfs);
			registerEventListeners(_sfs);
			
			_gameRooms = new Vector.<GameRoom>();
			ProxySignals.getInstance().screenTabChanged.add(onScreenTabChanged);
			ProxySignals.getInstance().gameLogUpdatedSignal.add(onGameLogUpdated);
			ProxySignals.getInstance().gameLogTrackDataSignal.add(onGameLogTrackDataUpdated);
			
			_pointRoomList		= new Vector.<SFSRoom>;
			_bestOfNList		= new Vector.<SFSRoom>;
			_pool101RummyList	= new Vector.<SFSRoom>;
			_pool201RummyList	= new Vector.<SFSRoom>;
			
			_playersNames		= new Dictionary(true);
			
		}
		
		public function initSFSConnection(host:String, port:int, httpPort:int, zone:String, isDebug:Boolean, userInfo:UserInfo):void
		{
			Logger.log("init SFS connection...");
			Logger.log("----------------------");
			Logger.log("  host: " + host);
			Logger.log("  port: " + port);
			Logger.log("  zone: " + zone);
			Logger.log("----------------------");
			
			_userInfo = userInfo;
			
			//_sfs.loadConfig(configUrl);
			var config:ConfigData = new ConfigData();
			config.host = host;
			config.port = port;
			config.httpPort = httpPort;
			config.zone = zone;
			config.debug = false;//isDebug;
			_sfs.connectWithConfig(config);
		}
		
		private function registerEventListeners(sfs:SmartFox):void
		{
			sfs.addEventListener(SFSEvent.CONNECTION, onConnection);
			sfs.addEventListener(SFSEvent.CONNECTION_LOST, onConnectionLost);
			sfs.addEventListener(SFSEvent.CONNECTION_RESUME, onConnectionResume);
			sfs.addEventListener(SFSEvent.CONNECTION_RETRY, onConnectionRetry);
			sfs.addEventListener(SFSEvent.CONNECTION_ATTEMPT_HTTP, onConnectionHttpAttempt);
			
			sfs.addEventListener(SFSEvent.LOGIN, onLoginSuccess);
			sfs.addEventListener(SFSEvent.LOGIN_ERROR, onLoginError);
			sfs.addEventListener(SFSEvent.ROOM_JOIN, onRoomJoin);
			sfs.addEventListener(SFSEvent.ROOM_JOIN_ERROR, onRoomJoinError);
			
			sfs.addEventListener(SFSEvent.ROOM_ADD, onRoomAdded);
			sfs.addEventListener(SFSEvent.ROOM_REMOVE, onRoomRemoved);
			sfs.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, onRoomVarUpdate);
			sfs.addEventListener(SFSEvent.USER_COUNT_CHANGE, onUserCountChanged);
			sfs.addEventListener(SFSEvent.USER_EXIT_ROOM, onUserExitRoom);
			
			
			sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
			sfs.addEventListener(SFSEvent.PUBLIC_MESSAGE, onPublicMessageReceived);
		}
		
		protected function onUserExitRoom(event:SFSEvent):void
		{
			trace("User Exit");
			trace(event.params.room);
		}
		
		private function registerLoggerEvents(sfs:SmartFox):void
		{
			sfs.logger.loggingLevel = LogLevel.INFO;
			sfs.logger.enableEventDispatching = true;
			sfs.logger.enableConsoleTrace = false;
			sfs.logger.addEventListener(LoggerEvent.INFO, onLoggerLog);
			sfs.logger.addEventListener(LoggerEvent.DEBUG, onLoggerLog);
			sfs.logger.addEventListener(LoggerEvent.WARNING, onLoggerLog);
			sfs.logger.addEventListener(LoggerEvent.ERROR, onLoggerLog);
			
			function onLoggerLog(event:LoggerEvent):void
			{
				Logger.log(String(event.type + ": " + event.params.message));
			}
		}
		
		protected function onRoomAdded(event:SFSEvent):void
		{
			ProxySignals.getInstance().roomAddedSignal.dispatch(event.params.room);
		}
		
		protected function onRoomRemoved(event:SFSEvent):void
		{
			ProxySignals.getInstance().roomRemovedSignal.dispatch(event.params.room);
		}
		
		protected function onRoomVarUpdate(event:SFSEvent):void
		{
			var changedVars:Array = event.params.changedVars;
			ProxySignals.getInstance().roomVarUpdateSignal.dispatch(event);
		}
		
		protected function onUserCountChanged(event:SFSEvent):void
		{
			ProxySignals.getInstance().userCountChangedSignal.dispatch(event.params.room);
		}
		
		private function onConnection(ev:SFSEvent):void
		{
			if (ev.params.success)
			{
				Logger.log("successfully connected!");
				ProxySignals.getInstance().disconnectionSignal.dispatch(false);
				
				var userId:String = _userInfo.id.toString();
				Logger.log("loggin in user: " + userId + " ...");
				_sfs.send(new LoginRequest(userId));
			}
		}
		
		private function onConnectionLost(ev:SFSEvent):void
		{
			Logger.log("connection Lost!");
			if(_isLoggedIn)
			{
				//show the disconnection popup
				ProxySignals.getInstance().disconnectionSignal.dispatch(true);
			}
		}
		
		private function onConnectionResume(ev:SFSEvent):void
		{
			Logger.log("connection resumed!");
			ProxySignals.getInstance().disconnectionSignal.dispatch(false);
		}
		
		private function onConnectionRetry(ev:SFSEvent):void
		{
			ProxySignals.getInstance().disconnectionSignal.dispatch(true);
			Logger.log("connection retry...");
		}
		
		private function onConnectionHttpAttempt(ev:SFSEvent):void
		{
			Logger.log("attempting http connection...");
		}
		
		private function onLoginSuccess(event:SFSEvent):void
		{
			_isLoggedIn	= true;
			Logger.log("login success for user: " + event.params.user + "!");
			
			if(event.params.user)
			{
				ProxySignals.getInstance().loginSuccessfulSignal.dispatch();
			}
			
			/** DO NOT REMOVE THIS LINE **/
			startConnAliveTimer(); //Start a timer that keeps connection alive with SFS
			/** END DO NOT REMOVE THIS LINE **/
		}
		
		private function onLoginError(ev:SFSEvent):void
		{
			Logger.log("login failed!");
		}
		
		public function attendanceBonusRequest(bonusCount:int):void
		{
			var data:SFSObject = new SFSObject();
			data.putInt("day", bonusCount);
			_sfs.send(new ExtensionRequest(ExtensionCommand.ATTENDANCE_BONUS, data));
		}
		
		public function roomJoinRequest(roomID:String, password:String, roomToLeave:Number, asSpectator:Boolean):void
		{
			_sfs.send(new JoinRoomRequest(roomID, password, roomToLeave, asSpectator)); 
		}
		
		public function sendQuickPlayRequest(buyIn:int, gameDef:int):void
		{
			// request create room
			rummyPlayNow([500, 2000], 1);
		}
		
		public function getJoinRoom(): Room
		{
			return _sfs.lastJoinedRoom;
		}
		
		public function getLastJoinedRoomID():String
		{
			if(_sfs.lastJoinedRoom != null)
			{
				return _sfs.lastJoinedRoom.name;
			}
			else
			{
				return null;
			}
		}
		
		private function onRoomJoin(ev:SFSEvent):void
		{
			ProxySignals.getInstance().roomJoinResultSignal.dispatch(true);
			//getGameRoom(ev.params.sourceRoom).messageProcessor.invoke("roomjoinsuccess", ev.params.params as SFSObject)
			if (_gameRooms.length < Constants.MAX_ALLOWED_ROOM)
				addGameRoom(ev.params.room);
			else
				Logger.log("rooms are full!");
		}
		
		private function onRoomJoinError(ev:SFSEvent):void
		{
			ProxySignals.getInstance().roomJoinResultSignal.dispatch(false);
			Logger.log("room join error!");
		}
		
		private function onExtensionResponse(evt:SFSEvent):void
		{
			var command:String = evt.params.cmd;
			var responseParams:Object = evt.params;
			
			Logger.log("response: " + command + ", for room: " + evt.params.sourceRoom);
			if (evt.params.sourceRoom == undefined)
				Logger.log("orphan message: " + command);
			if(command == "refilledchipsresponse")
			{
				var refilledChips:int = evt.params.params.getInt("refilledchips");
				ProxySignals.getInstance().refilledChipsSignal.dispatch(refilledChips);
			}
			
			if (command == "admmsg" && evt.params.sourceRoom == undefined)
			{
				// HACK: cheap way to filter commands without source room
				var playerId:int = responseParams.params.getLong("playerid");
				var title:String = responseParams.params.getUtfString("title");
				var message:String = responseParams.params.getUtfString("message");
				
				Logger.log("admmsg: " + title + "- " + message);
				ProxySignals.getInstance().admmsgSignal.dispatch(playerId , title , message);
			}
			else
			{
				var gameRoom:GameRoom = getGameRoom(evt.params.sourceRoom);
				if (gameRoom)
				{
					gameRoom.messageProcessor.invoke(command, responseParams);
				}
				else if (command == "raju")
				{
					var chips:int = responseParams.params.getLong("chips");
					var realMoney:int = responseParams.params.getLong("realmoney");
					
					Logger.log("raju => chips: " + chips + ", realMoney: " + realMoney);
					ProxySignals.getInstance().updateuseraccountSignal.dispatch(chips, realMoney);
				}
			}
		}
		
		private function onPublicMessageReceived(event:SFSEvent):void
		{
			var message:String = event.params.message;
			var room:SFSRoom = event.params.room;
			var sender:SFSUser = event.params.sender;
			var gameRoom:GameRoom = getGameRoom(room.id);
			if (gameRoom)
			{
				var player:PlayerImpl = GameUtil.getPlayerById(gameRoom.gameView.tableView.gameImpl, int(sender.name));
				var formattedMessage:String = (player && player.name ? player.name : sender.name) + " > " + message;
				var date:Date = new Date();
				var timeStr:String = "[" + int(date.hours).toString() + ":" + int(date.minutes).toString() + "]";
				gameRoom.chatLogs.chats += "\n" + timeStr + " " + formattedMessage;
				if (_focusedRoom == gameRoom)
					ProxySignals.getInstance().chatLogsRefreshSignal.dispatch(gameRoom.chatLogs, room.id);
			}
		}
		
		private function onGameLogUpdated(message:String, roomId:int):void
		{
			var gameRoom:GameRoom = getGameRoom(roomId);
			if (gameRoom)
			{
				var date:Date = new Date();
				var timeStr:String = "[" + int(date.hours).toString() + ":" + int(date.minutes).toString() + "]";
				gameRoom.chatLogs.logs += "\n" + timeStr + " " + message;
				if (_focusedRoom == gameRoom)
					ProxySignals.getInstance().chatLogsRefreshSignal.dispatch(gameRoom.chatLogs, roomId);
			}
		}
		
		private function onGameLogTrackDataUpdated(message:String, roomId:int):void
		{
			var gameRoom:GameRoom = getGameRoom(roomId);
			if (gameRoom)
			{
				var date:Date = new Date();
				var timeStr:String = "[" + int(date.hours).toString() + ":" + int(date.minutes).toString() + "]";
				gameRoom.gameTrackLogs.logs += "\n" + timeStr + " " + message;
				if (_focusedRoom == gameRoom)
					ProxySignals.getInstance().LogTrackDataSignal.dispatch(gameRoom.gameTrackLogs, roomId);
			}
		}
		
		private function disposeGameLogTrackData(roomId:int):void
		{
			var gameRoom:GameRoom = getGameRoom(roomId);
			if (gameRoom)
			{
				
			}
		}
		
		public function goToLobby(room:SFSRoom):void
		{
			if(room)
			{
				sendRoomInfo(room, true);
				var data:ISFSObject = new SFSObject();
				data.putLong("playerid", _userInfo.id);
				_sfs.send(new ExtensionRequest(ExtensionCommand.GO_TO_LOBBY, data, room));
				_sfs.send(new LeaveRoomRequest(room));
				Logger.log("request: " + ExtensionCommand.GO_TO_LOBBY+ ", from room: " + room.id);
			}
		}
		
		public function logOutRequest():void
		{
			if(_sfs.isConnected && _isLoggedIn)
			{
				Logger.log("Log out && disconnected !");
				_isLoggedIn	= false;
				stopConnAliveTimer();
				_sfs.send(new LogoutRequest());
				_sfs.disconnect();
			}
		}
		
		/**
		 * The client needs to keep its connection alive with SFS when it is not in game play mode.
		 * Keep pinging the server every 25 seconds. 
		 */
		public function startConnAliveTimer():void
		{
			_sfsTimer = new Timer(22000,0); //22 seconds = 22000 milliseconds
			_sfsTimer.addEventListener(TimerEvent.TIMER, onSfsTimer);
			_sfsTimer.start();
		}
		
		public function stopConnAliveTimer():void
		{
			if(_sfsTimer)
			{
				_sfsTimer.removeEventListener(TimerEvent.TIMER, onSfsTimer);
				_sfsTimer.stop();
				_sfsTimer.reset();
				_sfsTimer = null;
			}
		}
		protected function onSfsTimer(event:TimerEvent):void
		{
			//send a dummy message to SFS.
			SFSInterface.getInstance().sendConnectionAliveRequest();
			
		}
		
		public function purchaseRequest(productID:int, subProductID:int, skuid:int):void
		{
			log("purchaseRequest: product id:-" + productID + " and subProductID: " + subProductID);
			var data:ISFSObject = new SFSObject();
			data.putInt("subprodid", subProductID);
			data.putInt("pid", productID);
			data.putInt("skuid", skuid);
			_sfs.send(new ExtensionRequest(ExtensionCommand.PURCHASE_REQ, data, null));
		}
		
		public function attendanceBonusCollected(attendanceBonus:AttendanceBonusInfo):void
		{
			var data:SFSObject = new SFSObject();
			data.putClass("AttendanceBonus", attendanceBonus);
			
			_sfs.send(new ExtensionRequest(ExtensionCommand.COLLECTED_ATTENDANCE_BONUS, data, null));
			
			Logger.log("Attendance Bonus Collected!!!!!!");
		}
		
		public function sendChatMessage(msg:String):void
		{
			_sfs.send(new PublicMessageRequest(msg, null, _sfs.lastJoinedRoom));
		}
		
		public function JoinRoomWithRoomID(roomID:String, password:String, roomToLeave:Number, asSpectator:Boolean):void
		{
			if(_sfs.lastJoinedRoom != null)
			{
				_sfs.send(new JoinRoomRequest(roomID, password, _sfs.lastJoinedRoom.id, asSpectator));
			}
			else
			{
				_sfs.send(new JoinRoomRequest(roomID, password, NaN, asSpectator));
			}
		}
		
		public function QuickJoin(roomName:String, buyIn:int, isSpectator:Boolean = false, isMytable:Boolean = false):void
		{
			trace("Room name.....",roomName);
			var data:ISFSObject = new SFSObject();
			data.putUtfString("ipaddress", "0.0.0.0");
			data.putUtfString("RoomName", roomName);
			data.putLong("buyin", buyIn);
			data.putBool("spectator", isSpectator);
			data.putBool("mytable", isMytable);
			
			_sfs.send(new ExtensionRequest(ExtensionCommand.JOIN, data, null));
			Logger.log("request: " + ExtensionCommand.JOIN);
			
		}
		
			
		public function validateJoin(room:Room):void
		{
			
		ProxySignals.getInstance().buyInFromLobbySignal.dispatch(room);
			
			/*var data:ISFSObject = new SFSObject();
			data.putUtfString("RoomName", roomName);
			
			_sfs.send(new ExtensionRequest(ExtensionCommand.ValidateJoin, data, null));
			Logger.log("request: " + ExtensionCommand.ValidateJoin);*/
		}
		
		public function rejoin(highestPoints:int, room:SFSRoom, cancled:Boolean):void
		{
			var command:String = cancled ? ExtensionCommand.REJOIN_CANCEL : ExtensionCommand.REJOIN;
			var tempData:ISFSObject = new SFSObject();
			tempData.putInt("highestpoints", highestPoints);
			_sfs.send(new ExtensionRequest(command, tempData, room));
			Logger.log("request: " + command + ", from room: " + room.id);
		}
		
		public function sendConnectionAliveRequest():void
		{
			if(_sfs == null) return;
			//var data:ISFSObject = new SFSObject();
			_sfs.send(new ExtensionRequest(ExtensionCommand.CONNECTION_ALIVE_REQ, null, null));
			Logger.log("request: " + ExtensionCommand.CONNECTION_ALIVE_REQ);
		}
		
		private function log(msg:String):void
		{
			Logger.log("[SFSInterface]: " + msg);
		}
		
		public function rummyPlayNow(stakeRange:Array, timeToSpend:int):void
		{
			var tempData:ISFSObject = new SFSObject();
			tempData.putIntArray("stakeValues", stakeRange);
			tempData.putInt("timetospend", timeToSpend);
			_sfs.send(new ExtensionRequest(ExtensionCommand.PLAY_NOW, tempData, null));
			Logger.log("request: " + ExtensionCommand.PLAY_NOW);
		}
		
		public function sendPublicMessage(message:String, roomId:int):void
		{
			var gameRoom:GameRoom = getGameRoom(roomId);
			_sfs.send(new PublicMessageRequest(message, null, gameRoom.gameView.room));
		}
		
		public function cardPicked(pickedFrom:int, room:SFSRoom):void
		{
			var len:int	= room.spectatorList.length;
			var user:SFSUser;
			for(var i:int=0; i<len; i++)
			{
				user	= room.spectatorList[i];
				if(user.isItMe)
					return;
			}
			var tempData:ISFSObject = new SFSObject();
			tempData.putInt("pickedfrom", pickedFrom);
			_sfs.send(new ExtensionRequest(ExtensionCommand.CARD_PICKED, tempData, room));
			Logger.log("request: " + ExtensionCommand.CARD_PICKED + ", from room: " + room.id);
		}
		
		public function cardDiscarded(cardImpl:CardImpl, room:SFSRoom):void
		{
			var tempData:ISFSObject = new SFSObject();
			tempData.putClass("CardImpl", cardImpl);
			_sfs.send(new ExtensionRequest(ExtensionCommand.CARD_DISCARDED, tempData, room));
			Logger.log("request: " + ExtensionCommand.CARD_DISCARDED + ", from room: " + room.id);
		}
		
		public function dropMe(room:SFSRoom, isLeaveTable:Boolean=false, dropedBeforeLeaveTable:Boolean=false):void
		{
			if(room && _sfs.isConnected)
			{
				var tempData:ISFSObject = new SFSObject();
				tempData.putBool("isleavetable", isLeaveTable);
				tempData.putBool("isdropandleavetable", dropedBeforeLeaveTable);
				
				_sfs.send(new ExtensionRequest(ExtensionCommand.DROP_ME, tempData, room));
				Logger.log("request: " + ExtensionCommand.DROP_ME + ", from room: " + room.id);
			}
		}
		
		public function initShow(room:SFSRoom, handCards:HandCardsImpl, discardedCard:CardImpl):void
		{
			var obj:ISFSObject		= new SFSObject();
			obj.putClass("HandCardsImpl", handCards);
			obj.putClass("CardImpl", discardedCard);
			
			_sfs.send(new ExtensionRequest(ExtensionCommand.INIT_SHOW, obj, room));
			Logger.log("request: " + ExtensionCommand.INIT_SHOW+ ", from room: " + room.id);
		}
		
		public function declare(handCards:HandCardsImpl, discardedCard:CardImpl, room:SFSRoom, isDeclared:Boolean):void
		{
			if (!handCards || !discardedCard)
				return;
			
			var tempData:ISFSObject = new SFSObject();
			tempData.putClass("HandCardsImpl", handCards);
			tempData.putClass("CardImpl", discardedCard);
			tempData.putBool("isSubmitted", false);
			tempData.putBool("isDeclared", isDeclared);
			_sfs.send(new ExtensionRequest(ExtensionCommand.DECLARE, tempData, room));
			Logger.log("request: " + ExtensionCommand.DECLARE + ", from room: " + room.id);
		}
		
		public function submit(handCards:HandCardsImpl, room:SFSRoom, isSubmitted:Boolean):void
		{
			// technically a declare but without any discarded card
			if (!handCards)
				return;
	
			var tempData:ISFSObject = new SFSObject();
			tempData.putClass("HandCardsImpl", handCards);
			tempData.putClass("CardImpl", new CardImpl());
			tempData.putBool("isSubmitted", isSubmitted);
			tempData.putBool("isDeclared", false);
			_sfs.send(new ExtensionRequest(ExtensionCommand.DECLARE, tempData, room));
			Logger.log("request: " + ExtensionCommand.DECLARE + ", from room: " + room.id);
		}
		
		public function sendBuyIn(amount:int, room:SFSRoom):void
		{
			var tempData:ISFSObject = new SFSObject();
			tempData.putLong("buyInAmount", amount);
			_sfs.send(new ExtensionRequest(ExtensionCommand.BUYIN, tempData, room));
			Logger.log("request: " + ExtensionCommand.BUYIN + ", from room: " + room.id);
		}
		
		public function manualSplitConfirmation(confirm:Boolean, room:SFSRoom):void
		{
			var command:String = (confirm ? ExtensionCommand.MANUAL_SPLIT_ACCEPT : ExtensionCommand.MANUAL_SPLIT_REJECT);
			_sfs.send(new ExtensionRequest(command, null, room));
			Logger.log("request: " + command + ", from room: " + room.id);
		}
		
		public function getRoomList():Array
		{
			return _sfs.roomList;
		}
		
		public function addGameRoom(room:SFSRoom):void
		{
			var newRoom:GameRoom = getGameRoom(room.id);
			if (newRoom)
				return;
			
			newRoom = new GameRoom(room);
			_gameRooms.push(newRoom);
			_mainStage.addChild(newRoom.gameView);
			_focusedRoom = newRoom;
			ProxySignals.getInstance().gameRoomAdded.dispatch(room.id, GameStatsView.getRoomNameStringByGroupId(room));
			ProxySignals.getInstance().chatLogsRefreshSignal.dispatch(newRoom.chatLogs, room.id);
			ProxySignals.getInstance().LogTrackDataSignal.dispatch(newRoom.gameTrackLogs, room.id);
		}
		
		public function closeRoom(roomId:int, notify:Boolean):void
		{
			ProxySignals.getInstance().roomJoinResultSignal.dispatch(false); // FIXME
			
			var room:GameRoom = getGameRoom(roomId);
			if (!room)
				return;
			
			_gameRooms.splice(_gameRooms.indexOf(room), 1);
			room.close(notify);
			room = null;
			ProxySignals.getInstance().gameRoomRemoved.dispatch(roomId);
			
			// set the root for the popup
			PopUpManager.root = _gameRooms.length > 0
				? _gameRooms[_gameRooms.length - 1].gameView
				: Starling.current.stage;
		}
		
		public function isSpectator(roomId:int):Boolean
		{
			var sfsRoom:SFSRoom;
			var spectatorsLen:int;
			var user:SFSUser;
			for (var i:int = 0; i < _gameRooms.length; i++)
			{
				if (_gameRooms[i] && _gameRooms[i].gameView.room.id == roomId)
				{
					sfsRoom	=_gameRooms[i].gameView.room;
					spectatorsLen	= sfsRoom.spectatorList.length;
					
					for(var j:int=0; j<spectatorsLen; j++)
					{
						user	= sfsRoom.spectatorList[i];
						
						if(user && user.isItMe)
							return true;
					}
				}
			}
			
			return false;
		}
		
		public function getGameRoom(roomId:int):GameRoom
		{
			for (var i:int = 0; i < _gameRooms.length; i++)
			{
				if (_gameRooms[i] && _gameRooms[i].gameView.room.id == roomId)
					return _gameRooms[i];
			}
			return null;
		}
		
		public function onScreenTabChanged(roomId:int, index:int=0):void
		{
			_focusedRoom = null;
			var gameRoom:GameRoom = getGameRoom(roomId);
			if (!gameRoom)
				return;
			
			_mainStage.addChild(gameRoom.gameView);
			_focusedRoom = gameRoom;
			gameRoom.gameView.onRoomFocusChanged(index);
			ProxySignals.getInstance().chatLogsRefreshSignal.dispatch(gameRoom.chatLogs, roomId);
		}
		
		public function refillChips():void
		{
			var data:ISFSObject = new SFSObject();
			data.putLong("playerid", _userInfo.id);
			
			_sfs.send(new ExtensionRequest(ExtensionCommand.REFILL_CHIPS, data, null));
			Logger.log("request: " + ExtensionCommand.REFILL_CHIPS );
		}
		
		public function notifyGameStart(room:SFSRoom):void
		{
			_sfs.send(new ExtensionRequest(ExtensionCommand.NOTIFY_GAME_START, null, room));
			Logger.log("request: " + ExtensionCommand.NOTIFY_GAME_START );
		}
		
		public function setUserVariables(key:String, value:Boolean):void
		{
			var userVars:Array	= [];
			userVars.push(new SFSUserVariable(key, value));
			
			_sfs.send(new SetUserVariablesRequest(userVars));
		}
		
		public function getMyTable():void
		{
			
		}
		
		public function updateRoomVariable(name:String, value:Boolean, room:Room=null):void
		{
			if(room == null)
				room	= _sfs.lastJoinedRoom;
			var settingArr:RoomVariable = new SFSRoomVariable("LeaveTable", value);
			_sfs.send( new SetRoomVariablesRequest( [settingArr], room ));
		}
		
		public function sendRoomCloseNotify(room:SFSRoom):void
		{
			var tempData:ISFSObject = new SFSObject();
			tempData.putUtfString("roomname", room.name);
			_sfs.send(new ExtensionRequest(ExtensionCommand.GAMECLOSENOTIFY, tempData, room));
			Logger.log("request: " + ExtensionCommand.GAMECLOSENOTIFY);
		}
		
		public function sendRoomInfo(room:SFSRoom=null, isLeaveTable:Boolean=false):void
		{
			// atleast player needs to join 1 room
			if(_gameRooms.length >0 || room)
			{
				if(isMiddleJoin)
					isLeaveTable	= isMiddleJoin;
				if(room == null)
				{
					for(var i:int=0; i<_gameRooms.length; i++)
					{
						room	= _gameRooms[i].gameView.room;
						sendLeaveTableInfo(room, isLeaveTable);
					}
				}
				else
				{
					sendLeaveTableInfo(room, isLeaveTable);
				}
			}
		
		}
		
		private function sendLeaveTableInfo(room:SFSRoom, isLeaveTable:Boolean):void
		{
			var user:User	= room.getUserByName(userInfo.id+"");
			var isSpectator:Boolean	= user.isSpectator;
			if(isSpectator)
				return;
			
			if(!isLeaveTable)
			{
				var leaveTableVar:RoomVariable	= room.getVariable("isleavetable");
				isLeaveTable					= leaveTableVar ? leaveTableVar.getValue():false;
			}
			
			var data:ISFSObject = new SFSObject();
			data.putBool("isleavetable", isLeaveTable);
			data.putUtfString("roomname", room.name);
			Logger.log("request: " + ExtensionCommand.MYTABLE + "Value  " + isLeaveTable);
			_sfs.send(new ExtensionRequest(ExtensionCommand.MYTABLE, data,  room));
		}
		
		public function setPlayerNameById(playerId:int, playerName:String):void
		{
			_playersNames[playerId]	= playerName;
		}
		
		public function getPlayerNameById(playerId:int):String
		{
			return _playersNames[playerId];	
		}
		
		public function flushPlayerNamesOnGameEnd():void
		{
			_playersNames	= null;
			_playersNames	= new Dictionary(true);
		}
		
		public function killConnection():void
		{
			_sfs.killConnection();
		}
		
		public function sendAvatarInfo(url:String):void
		{
			var data:ISFSObject = new SFSObject();
			data.putUtfString("iconurl", url);
			data.putLong("playerid", _userInfo.id);
			_sfs.send(new ExtensionRequest(ExtensionCommand.UPDATE_ICON, data, null));
			Logger.log("request: " + ExtensionCommand.UPDATE_ICON);
		}
		
		public function sendGameLogInfo(displayId:String, log:String, room:SFSRoom):void
		{
			trace();
			/*var data:ISFSObject = new SFSObject();
			data.putUtfString("displayid", displayId);
			data.putUtfString("logs", log);
			_sfs.send(new ExtensionRequest(ExtensionCommand.SAVE_GAME_LOGS, data, room));
			Logger.log("request: " + ExtensionCommand.SAVE_GAME_LOGS);*/
		}
		
		public function get userInfo():UserInfo { return _userInfo; }
		public function set mainStage(value:Sprite):void { _mainStage = value; }
		public function get GameRooms():Vector.<GameRoom>{ return _gameRooms; }
		public function get FocusedRoom():GameRoom{ return _focusedRoom; }
		public function get pointsRoomList():Vector.<SFSRoom> {  return _pointRoomList; }
		public function get bestOfNRoomList():Vector.<SFSRoom> { return _bestOfNList; }
		public function get pool101RoomList():Vector.<SFSRoom> { return _pool101RummyList; }
		public function get pool201RoomList():Vector.<SFSRoom> { return _pool201RummyList; }
		public function get isMiddleJoin():Boolean	{	return _isMiddleJoin;	}
		public function set isMiddleJoin(value:Boolean):void {	_isMiddleJoin = value;	}

		
	}	
}