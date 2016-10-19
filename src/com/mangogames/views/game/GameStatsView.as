package com.mangogames.views.game
{
	import com.mangogames.managers.ConfigManager;
	import com.smartfoxserver.v2.entities.SFSRoom;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	import starling.utils.HAlign;
	
	import utils.Fonts;
	import utils.ScaleUtils;
	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class GameStatsView extends Sprite
	{
		private var _txtGame:TextField;
		private var _txtGameId:TextField;
		private var _txtStringGameId:TextField;
		private var _txtBet:TextField;
		private var _txtPrize:TextField;
		private var _lblPrize:TextField;
		private var _lblGameDBId:TextField;
		
		private var _room:SFSRoom;
		private var gameStatsBg:Image
		private var PADDING:int	= 10;
		
		public function GameStatsView()
		{
			super();
			
			initView();
			hidePrizeMoney();
		}
		
		private function initView():void
		{
			var label:TextField;
			var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 14;
			
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, fontSize, Fonts.getInstance().colorWhite);
			// game
			label = new TextField(1, 1, "Game:", tf);
			label.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			label.format.horizontalAlign = HAlign.LEFT;
			addChild(label);
			label.y = 10;
			
			_txtGame = new TextField(1, 1, "Game Name", tf);
			_txtGame.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtGame.format.color	= Color.YELLOW;
			_txtGame.format.horizontalAlign = HAlign.LEFT;
			addChild(_txtGame);
			_txtGame.x = label.x + label.width+ PADDING;
			_txtGame.y = 10;
			
			label = new TextField(1, 1, "Bet:", tf);
			label.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			label.format.horizontalAlign = HAlign.LEFT;
			addChild(label);
			label.x = _txtGame.x + _txtGame.width + PADDING;
			label.y = 10;
			
			_txtBet = new TextField(1, 1, "", tf);
			_txtBet.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtBet.format.horizontalAlign = HAlign.LEFT;
			_txtBet.format.color	= Color.YELLOW;
			addChild(_txtBet);
			_txtBet.x = label.x + label.width+ PADDING; //65;
			_txtBet.y = 10;
			
			_txtStringGameId = new TextField(1, 1, "Game Id:", tf);
			_txtStringGameId.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtStringGameId.format.horizontalAlign = HAlign.LEFT;
			addChild(_txtStringGameId);
			_txtStringGameId.x = _txtBet.x + _txtBet.width+PADDING;
			_txtStringGameId.y = 10;
			_txtStringGameId.visible	= false;
			
			_txtGameId = new TextField(1, 1, "", tf);
			_txtGameId.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtGameId.format.horizontalAlign = HAlign.LEFT;
			_txtGameId.format.color	= Color.YELLOW;
			addChild(_txtGameId);
			_txtGameId.x = _txtStringGameId.x + _txtStringGameId.width+PADDING; //65;
			_txtGameId.y = 10;
			_txtGameId.visible	= false;
			
			_lblPrize = new TextField(1, 1, "Prize:", tf);
			_lblPrize.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			_lblPrize.format.horizontalAlign = HAlign.LEFT;
			addChild(_lblPrize);
			_lblPrize.x = _txtGameId.x + _txtGameId.width+PADDING; //10;
			_lblPrize.y = 10;
			
			_txtPrize = new TextField(1, 1, "0", tf);
			_txtPrize.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtPrize.format.horizontalAlign = HAlign.LEFT;
			_txtPrize.format.color	= Color.YELLOW;
			addChild(_txtPrize);
			_txtPrize.x =  _lblPrize.x + _lblPrize.width+PADDING; //65;
			_txtPrize.y = 10;
			
			_lblGameDBId = new TextField(1, 1, "Game DB Id: ", tf);
			_lblGameDBId.autoSize	= TextFieldAutoSize.BOTH_DIRECTIONS;
			_lblGameDBId.format.horizontalAlign = HAlign.LEFT;
			_lblGameDBId.format.color	= Color.YELLOW;
			//addChild(_lblGameDBId);
			_lblGameDBId.x = 750;
			_lblGameDBId.y = 10;
			_lblGameDBId.visible = false;
		}
		
		public function setRoom(room:SFSRoom):void
		{
			_room = room;
			_txtGame.text = getRoomNameStringByGroupId(room);
			//_txtGameId.text = room.id.toString();
			_txtBet.text = Number(room.getVariable("Bet").getIntValue() / 100).toFixed(2).toString();
			_txtStringGameId.x = _txtBet.x + _txtBet.width+PADDING;
			_txtGameId.x = _txtStringGameId.x + _txtStringGameId.width+PADDING;
		}
		
		private var _isSizeAdjusted:Boolean;
		public function setPrizeMoney(amount:int):void
		{
			if(!_isSizeAdjusted)
			{
				_isSizeAdjusted		= true;
				//gameStatsBg.height+= 20;
			}
			_txtPrize.text = Number(amount / 100).toFixed(2).toString();
			_txtPrize.visible = true;
			_lblPrize.visible = true;
		}
		
		public function hidePrizeMoney():void
		{
			_txtPrize.visible = false;
			_lblPrize.visible = false;
		}
		
		public function disableGameIdText():void
		{
			if(_txtGameId) _txtGameId.visible				= false;
			if(_txtStringGameId) _txtStringGameId.visible	= false;
		}
		
		public function enableGameIdText():void
		{
			if(_txtGameId) _txtGameId.visible				= true;
			if(_txtStringGameId) _txtStringGameId.visible	= true;
		}
		
		public function setRound(round:String, roundCount:int):void
		{
			enableGameIdText();	
			_txtGameId.text = roundCount>0?round +" - "+roundCount:round;
			_lblPrize.x = _txtGameId.x + _txtGameId.width+PADDING;
			_txtPrize.x =  _lblPrize.x + _lblPrize.width+PADDING;
			// make this the unique game id for point games
			// useColon basically says whether it is a point game or not
	/*		if (useColon)
			{
				var displayId:String = String((_room.id % 1000) + 1000);
				displayId = String(round + displayId.substring(1));
				_lblGameDBId.visible = SettingsManager.USE_DEV; // show it only for dev/test games
				_lblGameDBId.text = displayId;
			}*/
		}
		
		public function setGameDBId(dbId:Number):void
		{
			_lblGameDBId.visible = ConfigManager.USE_DEV; // show it only for dev/test games
			_lblGameDBId.text = "Game DB Id: " + dbId.toString();
		}
		
		public static function getRoomNameStringByGroupId(room:SFSRoom):String
		{
			switch (room.groupId)
			{
				case "201": return "201 Pool";
				case "101": return "101 Pool";
				case "100": return "PR - Rummy";
				case "102": return room.getVariable("GameTypeName").getStringValue();
			}
			
			return "";
		}
	}
}