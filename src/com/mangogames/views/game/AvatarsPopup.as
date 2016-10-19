package com.mangogames.views.game
{
	import com.mangogames.managers.ConfigManager;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.services.SFSInterface;
	
	import flash.geom.Rectangle;
	
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.GlowFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import utils.Fonts;
	
	public class AvatarsPopup extends Sprite
	{
		private var _header:TextField;
		private var COLOUMS_COUNT:int	= 6;
		private var ROWS_COUNT:int		= 4;
		private var _selectedAvatr:Button;
		private var _tickMark:Image;
		private var _callBack:Function;
		private var _isAvatarSelected:Boolean;
		
		public function AvatarsPopup(callBack:Function)
		{
			super();
			_callBack	= callBack;
			init();
		}
		
		private function init():void
		{
			var bgTexture:Texture	= MangoAssetManager.I.getTexture("score_board_popup");
			var rect:Rectangle = new Rectangle( 10, 30, 160,160 );
			/*var textures:Scale9Textures = new Scale9Textures( bgTexture, rect );
			
			var bg:Scale9Image = new Scale9Image( textures, 1 );*/
			var img:Image	= new Image(bgTexture);
			img.scale9Grid	= new Rectangle( 10, 30, 160,160 );
			var bg:Sprite	= new Sprite();
			bg.addChild(img);
			bg.width = bg.width-120;
			this.addChild( bg );
			
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, 12, Color.WHITE);
			_header = new TextField(1, 1, "SELECT YOUR AVATAR", tf);
			_header.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_header.format.bold	= true;
			_header.x	= (bg.width-_header.width)/2;
			_header.y	= 2;
			bg.addChild(_header);	
			
			var btnClose:Button = new Button(MangoAssetManager.I.getTexture("close_btn"));
			addChild(btnClose);
			btnClose.x = bg.width-btnClose.width-10;
			btnClose.y = 3;
			btnClose.scaleX = btnClose.scaleY = 1.2;
			btnClose.addEventListener(Event.TRIGGERED, onClose);
			
			var btnOk:Button = new Button(MangoAssetManager.I.getTexture("ok_btn"));
			addChild(btnOk);
			btnOk.x = (bg.width-btnOk.width)/2;
			btnOk.y = bg.height -50;
			btnOk.addEventListener(Event.TRIGGERED, onClose);
			
			addFemaleAvatars();
			addMaleAvatars();
		}
		
		private function addFemaleAvatars():void
		{
			var posX:int	= 52;
			var posY:int	= 60;
			var Gap:int		= 60;
			var W:int		= 35;
			var H:int		= 30;
			var X:int;
			var Y:int;
			
			for(var i:int=0; i<6; i++)
			{
				X	= (posX+W)* i+Gap;
				Y	= posY;
				addAvatar("avatar"+(i+1), X, Y, i);
			}
		}
		
		private function addMaleAvatars():void
		{
			var posX:int	= 52;
			var posY:int	= 60;
			var Gap:int		= 60;
			var W:int		= 35;
			var H:int		= 30;
			var X:int;
			var Y:int;
			var xCount:int = 0;
			var yCount:int = 0;
			
			for(var i:int=6; i<24; i++)
			{
				if(i%6==0)
				{
					xCount	= 0;
					yCount++;
				}
				else
				{
					xCount++;
				}
				X	= (posX+W)* xCount+Gap;
				Y	= (posY+H)* yCount+65;
				addAvatar("avatar"+(i+1), X, Y, i);
			}
		}
		
		private function addAvatar(name:String, x:int, y:int, i:int):void
		{
			var img:Button	= new Button(MangoAssetManager.I.getTexture(name));
			img.x			= x;
			img.y			= y;
			img.alignPivot();
			addChild(img);
			img.addEventListener(Event.TRIGGERED, onAvatarClick);
			
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, 12, Color.GREEN);
			var avatrName:TextField	= new TextField(1, 1, "avatar"+(i+1), tf);
			avatrName.autoSize		= TextFieldAutoSize.BOTH_DIRECTIONS;
			avatrName.x				= x-img.width/2;
			avatrName.y				= y+img.height/2+1;
			addChild(avatrName);
			
			if(_tickMark == null)
			{
				_tickMark				= new Image(MangoAssetManager.I.getTexture("tick_mark"));
				addChild(_tickMark);
				_tickMark.visible		= false;
			}
			img.name	= "avatar"+(i+1);
			_isAvatarSelected			= true;
		}
		
		private function onAvatarClick(event:Event):void
		{
			var currentAvatar:Button	= Button(event.target);
			if(_selectedAvatr == currentAvatar)
				return;
			if(_selectedAvatr)
			{
				_selectedAvatr.scaleX = _selectedAvatr.scaleY = 1;
				_selectedAvatr.filter = null;
			}
				
			_selectedAvatr			= currentAvatar;
			currentAvatar.scaleX 	= 1.2;
			currentAvatar.scaleY 	= 1.2;
			var glowFilter:GlowFilter	= new GlowFilter();
			currentAvatar.filter	= glowFilter; //BlurFilter.createGlow(16776960, 1, 2, 1);
			
			_tickMark.x				= currentAvatar.x+currentAvatar.width/2//+_tickMark.height;
			_tickMark.y				= currentAvatar.y-currentAvatar.height/2;
			_tickMark.visible		= true;
			
			var avatarUrl:String;
			if(ConfigManager.I.SERVER_IP == Constants.PRODUCTION_IP)
				avatarUrl = "http://play.ace2jak.com/game_client/profiles/"+currentAvatar.name +".png"; //"http://104.238.81.49/game_client/profiles/" +gender +event.target.name +ext;
			else if(ConfigManager.I.SERVER_IP == Constants.TEST)
				avatarUrl = "https://testplay.ace2jak.com/game_client/profiles/"+currentAvatar.name +".png";
			
			SFSInterface.getInstance().userInfo.avatarId	= avatarUrl; 
			
			SFSInterface.getInstance().sendAvatarInfo(avatarUrl);
			
		}
		
		private function onClose():void
		{
			if(_tickMark && _tickMark.visible)
				_callBack.call(true,true);
			else
				_callBack.call(true, false);
			
			PopUpManager.removePopUp(this);
		}
	}
}