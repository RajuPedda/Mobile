package com.mangogames.views.game
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.models.IGame;
	import com.mangogames.rummy.model.impl.BestOfNGameImpl;
	import com.mangogames.rummy.model.impl.PointsGameImpl;
	import com.mangogames.rummy.model.impl.SyndicateGameImpl;
	import com.smartfoxserver.v2.entities.SFSRoom;
	
	import flash.geom.Rectangle;
	
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import utils.Fonts;
	
	public class GameRules extends Sprite
	{
		private var label:TextField
		private var _closeCallBack:Function
		private var _btnOk:Button;
		private var _gameView:GameView;
		private var _header:TextField;
		
		public function GameRules(gameType:IGame, callback:Function, gameView:GameView)
		{
			super();
			_closeCallBack	= callback;
			_gameView		= gameView;
			initScreen(gameType);
		}
		
		private function initScreen(gameType:IGame):void
		{
			var bgTexture:Texture	= MangoAssetManager.I.getTexture("history_popup");
			var rect:Rectangle = new Rectangle( 10, 30, 160,160 );
			/*var textures:Scale9Textures = new Scale9Textures( bgTexture, rect );
			
			var bg:Scale9Image = new Scale9Image( textures, 1 );*/
			var bg:Sprite	= new Sprite();
			
			var img:Image	= new Image(bgTexture);
			img.scale9Grid	= new Rectangle( 10, 30, 160,160 );
			bg.addChild(img);
			bg.width = 395;
			bg.height = 430;
			this.addChild( bg );
			
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, 12, Color.WHITE);
			_header = new TextField(1, 1, "Game Rules", tf);
			_header.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_header.x	= (bg.width-_header.width)/2;
			_header.y	= 2;
			bg.addChild(_header);	
			
			
			label = new TextField(350, 1, "", tf);
			label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			label.x	= 10;
			label.y	= 30;
			bg.addChild(label);	
			
			_btnOk = new Button(MangoAssetManager.I.getTexture("ok_btn"));
			addChild(_btnOk);
			_btnOk.x = (bg.width-_btnOk.width)/2
			_btnOk.y = bg.height -50;
			_btnOk.addEventListener(Event.TRIGGERED, onClose);
			
			var btnClose:Button = new Button(MangoAssetManager.I.getTexture("close_btn"));
			addChild(btnClose);
			btnClose.x = bg.width-btnClose.width-10;
			btnClose.y = 3;
			btnClose.scaleX = btnClose.scaleY = 1.2;
			btnClose.addEventListener(Event.TRIGGERED, onClose);
			
			if(gameType is PointsGameImpl)
				loadPRrules();
			else if(gameType is BestOfNGameImpl)
				loadBestOfNrules(gameType);
			else if(gameType is SyndicateGameImpl)
				loadPoolGameRules(gameType);
		}
		
		private function onClose():void
		{
			_closeCallBack.call();
		}
		
		private function loadPRrules():void
		{
			for each(var gameTypeXml:XML in MangoAssetManager.I.gameRules.gametype)
			{
				if(gameTypeXml.@gameName == "pointrummy")
				{
					label.text			= gameTypeXml;
				}
			}
		}
		
		private function loadPoolGameRules(gameType:IGame):void
		{
			for each(var gameTypeXml:XML in MangoAssetManager.I.gameRules.gametype)
			{
				if((gameType as SyndicateGameImpl).maxScore	== 201 && gameTypeXml.@gameName == "pool201")
				{
						label.text			= gameTypeXml;
				}
				if((gameType as SyndicateGameImpl).maxScore == 101 && gameTypeXml.@gameName == "pool101")
				{
					label.text			= gameTypeXml;
				}
			}
		}
		
		private function loadBestOfNrules(gameType:IGame):void
		{
			var gameName:String = GameStatsView.getRoomNameStringByGroupId(SFSRoom(_gameView.room))
				
			for each(var gameTypeXml:XML in MangoAssetManager.I.gameRules.gametype)
			{
				if(gameName=="Best of 2" && gameTypeXml.@gameName == "bestof2")
				{
					label.text			= gameTypeXml;
				}
				if(gameName=="Best of 3" && gameTypeXml.@gameName == "bestof3")
				{
					label.text			= gameTypeXml;
				}
				
			}
		}
		
	}
}