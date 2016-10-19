package com.mangogames.views.lobby
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.AbstractBaseView;
	import com.mangogames.views.popup.BuyInPopUp;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.SFSRoom;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.variables.RoomVariable;
	import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
	
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import air.net.URLMonitor;
	
	import feathers.controls.Check;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.controls.ScrollContainer;
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.controls.TabBar;
	import feathers.controls.ToggleButton;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	
	import logger.Logger;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	import utils.ControlUtils;
	import utils.Fonts;
	import utils.ScaleType;
	import utils.ScaleUtils;
	
	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	[Event(name="change",type="starling.events.Event")]
	
	public class LobbyScreenView extends AbstractBaseView
	{
		
		public function LobbyScreenView()
		{
			super();
			ProxySignals.getInstance().gameRoomAdded.add(onGameRoomAdded);
		}
		
		
		private var _headerContainer:Sprite;
		private var _bodyContainer:Sprite;
		private var _footerContainer:Sprite;
		
		private var _scrollList:ScrollContainer;
		private var isUserSelected2And6Players:Boolean;
		private var isUserSelected2players:Boolean;
		private var isUserSelected6players:Boolean;
		private var _playerAndTablesCount:TextField;
		private var _lobbySettings:LobbySettings;
		private var _myTableRooms:Array;
		private var lblTotalPlayer:TextField;
		private var lblTotalTable:TextField;
		
		public var moreBtn:Button;
		public var tablesBtn:Button;
		public var addChipsBtn:Button	
		
		private var _screenNavigator:ScreenNavigator;
		
		
		private var pointRoomList:Array 	= [];
		private var bestOfNList:Array 		= [];
		private var pool101RummyList:Array 	= [];
		private var pool201RummyList:Array 	= [];
		private var _engagedRooms:Vector.<SFSRoom> = new Vector.<SFSRoom>();
		private var _tablesView:TablesView;
		protected var _screen1Signal:Signal = new Signal();
		private var _stackScreenNavigator:StackScreenNavigator;
		private var screen1Item:StackScreenNavigatorItem;
		
		public function get screen1Signal():ISignal
		{
			return this._screen1Signal;
		}
		
		protected var _screen2Signal:Signal = new Signal();
		
		public function get screen2Signal():ISignal
		{
			return this._screen2Signal;
		}
		
		
		[PostConstruct]
		public function postConstruct():void
		{
			refreshRooms();
			initUI();
			initTabs();
		}
		
		private function onGameRoomAdded(roomId:int, roomName:String):void
		{
			dispatchEventWith("screen1Signal");
		}
		
		private function initTabs():void
		{
			var url:URLMonitor	= new URLMonitor(new URLRequest("https://ace2jak.com/"));
			url.addEventListener(StatusEvent.STATUS, statusChangedHandler);
			url.start();
			
			_bodyContainer		= new Sprite();
			addChild(_bodyContainer);
			
			_bodyContainer.x	= 0// (STAGE_WIDTH - _headerContainer.width)/2;
			_bodyContainer.y	= STAGE_HEIGHT/5;
			
			
			var tabs:TabBar = new TabBar();
			ScaleUtils.applyPercentageScale(tabs, 100, 10);
			//tabs.styleNameList.add("custom-tab");
			tabs.tabFactory = function():ToggleButton
			{
				var tab:ToggleButton = new ToggleButton();
				//tab.defaultSkin = new Image( MangoAssetManager.I.getTexture("type_box"));
				//tab.downSkin = new Image( MangoAssetManager.I.getTexture("type_box") );
				tab.labelFactory = function():ITextRenderer
				{
					var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
					textRenderer.styleProvider = null;
					var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 20*ScaleUtils.scaleFactorNoBorder : 20;
					textRenderer.textFormat = new TextFormat( "Source Sans Pro", fontSize, 0xFFFFFF );
					return textRenderer;
				}
					
				return tab;
			};
			
			tabs.dataProvider = new ListCollection(
				[
					{ label: "Point Rummy" , 	screen:"pointRummy"},
					{ label: "Best of N" , 		screen:"bestOfN"},
					{ label: "201 Pool" , 		screen:"201Pool"},
					{ label: "101 Pool" , 		screen:"101Pool"},
				]);
			_bodyContainer.addChild( tabs );
			tabs.addEventListener( Event.CHANGE, tabsChangeHandler );
			
			_screenNavigator = new ScreenNavigator();
			//point rummy
			var pointRummyItem:ScreenNavigatorItem	= new ScreenNavigatorItem(PointRummyScreen);
			pointRummyItem.properties.roomsList	= pointRoomList;
			pointRummyItem.properties.stageW	= STAGE_WIDTH;
			pointRummyItem.properties.stageH	= STAGE_HEIGHT;
			_screenNavigator.addScreen( "pointRummy", pointRummyItem);
			_screenNavigator.showScreen("pointRummy");
			
			// Best of N
			var bestOfNItem:ScreenNavigatorItem	= new ScreenNavigatorItem(BestOfNScreen);
			bestOfNItem.properties.roomsList	= bestOfNList;
			bestOfNItem.properties.stageW		= STAGE_WIDTH;
			bestOfNItem.properties.stageH		= STAGE_HEIGHT;
			bestOfNItem.setScreenIDForEvent("bestOfNEvent", "bestOfN");
			_screenNavigator.addScreen( "bestOfN", bestOfNItem);
			
			// 201 Pool
			var pool201Item:ScreenNavigatorItem	= new ScreenNavigatorItem(Pool201Screen);
			pool201Item.properties.roomsList	= pool201RummyList;
			pool201Item.properties.stageW		= STAGE_WIDTH;
			pool201Item.properties.stageH		= STAGE_HEIGHT;
			pool201Item.setScreenIDForEvent("201PoolEvent", "201Pool");
			_screenNavigator.addScreen( "201Pool", pool201Item);
			
			// 101 Pool
			var pool101Item:ScreenNavigatorItem	= new ScreenNavigatorItem(Pool101Screen);
			pool101Item.properties.roomsList	= pool101RummyList;
			pool101Item.properties.stageW		= STAGE_WIDTH;
			pool101Item.properties.stageH		= STAGE_HEIGHT;
			pool101Item.setScreenIDForEvent("101PoolEvent", "101Pool");
			_screenNavigator.addScreen( "101Pool", pool101Item);
			
			_screenNavigator.y	= tabs.y + tabs.height;
			_bodyContainer.addChild( _screenNavigator );
			
		}
		
		protected function statusChangedHandler(event:StatusEvent):void
		{
			trace(event);
		}
		
		private function tabsChangeHandler(event:Event):void
		{
			var tabs:TabBar = TabBar( event.currentTarget );
			_screenNavigator.showScreen( tabs.selectedItem.screen );
		}
		
		private function initUI():void
		{
			var bg:Image = MangoAssetManager.I.getImage("01", ScaleType.NO_BORDER);
			bg.width	 = STAGE_WIDTH;
			bg.height	 = STAGE_HEIGHT;
			addChild(bg);
			
			_headerContainer	= new Sprite();
			addChild(_headerContainer);
			
			var logo:Image	= MangoAssetManager.I.getImage("logo_05");
			ScaleUtils.applyPercentageScale(logo, 16, 16);
			_headerContainer.addChild(logo);
			logo.x		= (STAGE_WIDTH - logo.width)/2;
			logo.y		= logo.height/10;
			
			var signal:Image	= MangoAssetManager.I.getImage("network_full", ScaleType.NO_BORDER);
			_headerContainer.addChild(signal);
			signal.y			= signal.height/3;
			signal.x			= PADDING/3;
			
			var time:TextField		= ControlUtils.createCenteredLabel("", ScaleType.NO_BORDER);
			time.x			= signal.x+signal.width+PADDING/4;
			time.y			= signal.y;
			time.format.size	= Fonts.getInstance().mediumFont;
			
			var date:Date = new Date();
			time.text = date.toLocaleTimeString()+"\n" + date.toLocaleDateString()
			_headerContainer.addChild(time);
			
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void
			{
				var date:Date = new Date();
				time.text = date.toLocaleTimeString()+"\n" + date.toLocaleDateString()
			});
			timer.start();
			
			var userName:TextField		= ControlUtils.createCenteredLabel("Welcome  " + SFSInterface.getInstance().userInfo.name, ScaleType.NO_BORDER); //SFSInterface.getInstance().userInfo.name
			userName.x			= signal.x;
			userName.y			= _headerContainer.height - userName.height/2;
			//userName.format.color	= Color.YELLOW;
			_headerContainer.addChild(userName);
			
			//05_ui_btn_+
			addChipsBtn = new Button(MangoAssetManager.I.getTexture("addchip_btn"));
			ScaleUtils.applyPercentageScale(addChipsBtn, 4, 5); 
			_headerContainer.addChild(addChipsBtn);
			addChipsBtn.x		= STAGE_WIDTH - (addChipsBtn.width + PADDING/4);
			addChipsBtn.y		= addChipsBtn.height *2;
			//05_ui_bg_06
			
			var chipsBg:Image	= MangoAssetManager.I.getImage("05_ui_bg_06");
			ScaleUtils.applyPercentageScale(chipsBg, 18, 7);
			chipsBg.x		= addChipsBtn.x-(PADDING/4+chipsBg.width);
			chipsBg.y		= addChipsBtn.y //+ chipsBg.height/2;
			_headerContainer.addChild(chipsBg);
				
			
			var realChilps:TextField= ControlUtils.createCenteredLabel((SFSInterface.getInstance().userInfo.gold).toString(), ScaleType.NO_BORDER); //Number(SFSInterface.getInstance().userInfo.gold / 100).toFixed(2)
			realChilps.x			= chipsBg.x + chipsBg.width/2 - realChilps.width/2;
			realChilps.y			= chipsBg.y+chipsBg.height/6;
			//realChilps.format.size	= 18/ScaleUtils.scaleFactorNoBorder;
			_headerContainer.addChild(realChilps);
			
			var realChilpsStr:TextField= ControlUtils.createCenteredLabel("Real Chips", ScaleType.NO_BORDER); //Number(SFSInterface.getInstance().userInfo.gold / 100).toFixed(2)
			realChilpsStr.x			= chipsBg.x- (chipsBg.width/2+PADDING/4);
			realChilpsStr.y			= realChilps.y;
			_headerContainer.addChild(realChilpsStr);
			
			var playerCountBg:Image	= MangoAssetManager.I.getImage("05_ui_bg_07", ScaleType.NO_BORDER);
			_headerContainer.addChild(playerCountBg);
			playerCountBg.x		= STAGE_WIDTH - playerCountBg.width -10;
			
			
			
			_playerAndTablesCount	= ControlUtils.createCenteredLabel(" Players / " + " Tables", ScaleType.NO_BORDER); //Number(SFSInterface.getInstance().userInfo.gold / 100).toFixed(2)
			_headerContainer.addChild(_playerAndTablesCount);
			_playerAndTablesCount.x		= playerCountBg.x + playerCountBg.width/2 - _playerAndTablesCount.width/2;
			_playerAndTablesCount.y		= _playerAndTablesCount.y+_playerAndTablesCount.height/6;
			refreshPlayerAndTableCount();
			
			var line:Image	= MangoAssetManager.I.getImage("line", ScaleType.NO_BORDER);
			_headerContainer.addChild(line);
			line.width	= STAGE_WIDTH;
			line.y		= logo.y + logo.height;
			line.x		= (STAGE_WIDTH-line.width)/2;
			
			var playersBgContainer:Sprite	= new Sprite();
			_headerContainer.addChild(playersBgContainer);
			
			var playersPanel:Image	= MangoAssetManager.I.getImage("2_6_player_bg", ScaleType.NO_BORDER);
			//playersBgContainer.addChild(playersPanel);
			playersPanel.x		= (STAGE_WIDTH - playersPanel.width)/2;
			playersPanel.y		= line.y; 
			
			_headerContainer.x	= 0;
			
			_footerContainer	= new Sprite();
			addChild(_footerContainer); //
			
			var footerBg:Image	= MangoAssetManager.I.getImage("05_ui_bg_08", ScaleType.NO_BORDER);
			//footerBg.width		= STAGE_WIDTH;
			ScaleUtils.applyPercentageScale(footerBg, 100, 7);
			footerBg.x			= (STAGE_WIDTH-footerBg.width)/2;
			_footerContainer.addChild(footerBg);
			
			tablesBtn 		= ControlUtils.createButton("more_btn", "Tables", ScaleType.NO_BORDER);
			ScaleUtils.applyPercentageScale(tablesBtn, 12, 6);
			_footerContainer.addChild(tablesBtn);
			
			tablesBtn.x		= STAGE_WIDTH/2 - tablesBtn.width;
			tablesBtn.y		= tablesBtn.height/7;
			
			moreBtn 		= ControlUtils.createButton("more_btn", "", ScaleType.NO_BORDER);
			ScaleUtils.applyPercentageScale(moreBtn, 12, 6);
			_footerContainer.addChild(moreBtn);
			moreBtn.x		= STAGE_WIDTH/2 + tablesBtn.width/7.5;
			moreBtn.y		= moreBtn.height/7;
			
			var favaratesImg:Image	 = MangoAssetManager.I.getImage("favourite_btn", ScaleType.NO_BORDER);
		//	_footerContainer.addChild(favaratesImg);
			favaratesImg.x		= tablesBtn.x - (favaratesImg.width + favaratesImg.width/2);
			favaratesImg.y		= favaratesImg.height/3;
			
			var homeImg:Image	 = MangoAssetManager.I.getImage("home_btn", ScaleType.NO_BORDER);
			//_footerContainer.addChild(homeImg);
			homeImg.x			= moreBtn.x + moreBtn.width+homeImg.width/2;
			homeImg.y			= favaratesImg.height/3;
			
			_footerContainer.y	= STAGE_HEIGHT - footerBg.height;
		}
		
		public function refreshRooms():void
		{
			var funRooms:Array 	= new Array();
			var cashRooms:Array = new Array();
			_myTableRooms 		= new Array();
			
			// get all room-list
			var allRooms:Array = SFSInterface.getInstance().getRoomList();
			// filter rooms
			allRooms.forEach(filterRooms);
			
			// update counter
			refreshPlayerAndTableCount();
			
			// set rooms appropriately
			setRooms(cashRooms);
			//navPlayForFun.setRooms(funRooms);
			
			function filterRooms(...rest):void
			{
				var room:SFSRoom = rest[0];
				
				if (getIsMyTableRoom(room))
				{
					Logger.log("UserCount: " + room.userCount);
					Logger.log("MyTable: " + "true");
					_myTableRooms.push(room);
				}
					
				else
				{
					var funGame:Boolean = room.getVariable("RealOrFun").getIntValue() == 0;
					
					if (funGame)
						funRooms.push(room);
					else
						cashRooms.push(room);
				}
				
				// update total tables/players count
				if (getUserCount(room) > 0)
					_engagedRooms.push(room);
			}
			
			ProxySignals.getInstance().roomAddedSignal.removeAll();
			ProxySignals.getInstance().roomRemovedSignal.removeAll();
			ProxySignals.getInstance().roomVarUpdateSignal.removeAll();
			ProxySignals.getInstance().userCountChangedSignal.removeAll();
			
			ProxySignals.getInstance().roomAddedSignal.add(onRoomAdded);
			ProxySignals.getInstance().roomRemovedSignal.add(onRoomDelete);
			ProxySignals.getInstance().roomVarUpdateSignal.add(onRoomVarUpdate);
			ProxySignals.getInstance().userCountChangedSignal.add(onUserCountChanged);
		}
		
		private function getUserCount(sfsRoom:Room):int
		{
			var idNamePairs:SFSObject = SFSRoomVariable(sfsRoom.getVariable("Players")).getValue();
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
		
		public function setRooms(value:Array):void
		{
			
			for(var i:int = 0; i < value.length; i++)
			{
				var sfsRoom:SFSRoom = value[i];
				switch(sfsRoom.groupId)
				{
					case "100":
						pointRoomList.push(sfsRoom);
						break;
					case "102":
						bestOfNList.push(sfsRoom);
						break;
					case "101":
						pool101RummyList.push(sfsRoom);
						break;
					case "201":
						pool201RummyList.push(sfsRoom);
						break;
				}
			}
			
			/*navPoints.setRoomList(pointRoomList);
			navBestOfN.setRoomList(bestOfNList);
			nav101.setRoomList(pool101RummyList);
			nav201.setRoomList(pool201RummyList);*/
			
			/*navBestOfN.rbtnBestOf2.label = "Best of 2";
			navBestOfN.rbtnBestOf6.label = "Best of 3";*/
		}
		
		private function onRoomAdded(sfsRoom:SFSRoom):void
		{
			/*var list:RoomList = getRoomList(sfsRoom);
			if (!list)
			return;
			
			list.lstRooms.dataProvider.addItem(sfsRoom);*/
			trace("added");
			
		}
		
		
		private function onUserCountChanged(sfsRoom:SFSRoom):void
		{
			/*var list:RoomList = getRoomList(sfsRoom);
			if (!list)
				return;
			
			list.lstRooms.dataProvider.itemUpdated(sfsRoom);
			
			// update player/table count
			for (var i:int = 0; i < _engagedRooms.length; i++)
			{
				if (_engagedRooms[i] == sfsRoom)
				{
					_engagedRooms.splice(i, 1);
					break;
				}
			}
			if (sfsRoom.userCount > 0)
				_engagedRooms.push(sfsRoom);
			
			
			list.reArrangeRoomsBasedOnPriority(ArrayCollection(list.lstRooms.dataProvider).source, true);	
			refreshPlayerAndTableCount();*/
		}
		
		private function onRoomDelete(sfsRoom:SFSRoom):void
		{
			/*var list:RoomList = getRoomList(sfsRoom);
			if (!list)
				return;
			
			var index:int = list.lstRooms.dataProvider.getItemIndex(sfsRoom);
			if (index != -1)
				list.lstRooms.dataProvider.removeItemAt(index);
			
			for (var i:int = 0; i < _engagedRooms.length; i++)
			{
				if (_engagedRooms[i] == sfsRoom)
				{
					_engagedRooms.splice(i, 1);
					break;
				}
			}
			refreshPlayerAndTableCount();*/
		}
		
		private function onRoomVarUpdate(event:SFSEvent):void
		{
			/*var sfsRoom:SFSRoom		= event.params.room;
			var list:RoomList = getRoomList(sfsRoom);
			if (!list)
				return;
			
			var changedVars:Array = event.params.changedVars as Array;
			
			if (getIsMyTableRoom(sfsRoom, changedVars))
			{
				removeFromPreviousList(sfsRoom);
			}
			else
			{
				checkAndRemoveFromMyTableList(sfsRoom)
			}
			
			var index:int = list.lstRooms.dataProvider.getItemIndex(sfsRoom);
			if (index == -1)
				list.lstRooms.dataProvider.addItem(sfsRoom);
			list.lstRooms.dataProvider.itemUpdated(sfsRoom);
			
			list.reArrangeRoomsBasedOnPriority(ArrayCollection(list.lstRooms.dataProvider).source, true);*/
		}
		
		private function getIsMyTableRoom(sfsRoom:SFSRoom, changedVars:Array=null):Boolean
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
		
		public function refreshPlayerAndTableCount():void
		{
			var totalPlayers:int 	= 0;
			var totalTables:int 	= 0;
			for (var i:int = 0; i < _engagedRooms.length; i++)
			{
				if (_engagedRooms[i].userCount > 0)
				{
					totalPlayers += _engagedRooms[i].userCount;
					totalTables++;
				}
			}
			if(_playerAndTablesCount) _playerAndTablesCount.text	= totalPlayers+ " Players / "+ totalTables + " Tables";
		}
		
		[PreDestroy]
		public function preDestroy():void
		{
			cleanUp();
		}
		
		
		
		private function check_changeHandler(event:Event):void
		{
			if(Check(event.target)["name"] == "2player")
				isUserSelected2players	= Check(event.target).isSelected;
			else
				isUserSelected6players	= Check(event.target).isSelected;
			isUserSelected2And6Players	= false;
			
			if(isUserSelected2players && isUserSelected6players)
				isUserSelected2And6Players	= true;
			
		}
		
		
		public function showJoinedTables():void
		{
			if(_tablesView)
			{
				removeChild(_tablesView);
				_tablesView	= null;
			}
			else
			{
				_tablesView	= new TablesView(_myTableRooms, tablesBtn.width);
				ScaleUtils.applyPercentageScale(_tablesView, 12, 16);
				addChild(_tablesView);
				_tablesView.x	= tablesBtn.x;
				_tablesView.y	= _footerContainer.y;
			}
			
		}
		
		// show/destroy settings screen
		public function switchLobbySettings(logOutcallback:Function):void
		{
			if(_lobbySettings)
			{
				removeChild(_lobbySettings)
				_lobbySettings	= null;
			}
			else
			{
				_lobbySettings	= new LobbySettings(logOutcallback);
				ScaleUtils.applyPercentageScale(_lobbySettings, 18, 26);
				addChild(_lobbySettings);
				_lobbySettings.x	= moreBtn.x + (moreBtn.width-_lobbySettings.width)/2;
				_lobbySettings.y	= _footerContainer.y;
			}
		}
		
		private function cleanUp():void
		{
			
		}
		
		public function validateBuyIn(room:Room, reqAmount:int, balance:int):void
		{
			var buyInPopup:BuyInPopUp			= new BuyInPopUp(reqAmount, balance, function(buyInAmount:int):void
			{
				//var buyInValue:int	= buyInAmount;
				
				// when User didnt click on BuyIn Ok button
				// that means cancel 
				if(buyInAmount <0)
					trace();
				else
					SFSInterface.getInstance().QuickJoin(room.name, buyInAmount);
				
			}, true);
			PopUpManager.addPopUp(buyInPopup);
		}
		
	}
}