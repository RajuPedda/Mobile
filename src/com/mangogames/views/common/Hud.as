package com.mangogames.views.common
{
	import com.mangogames.audio.SoundDirector;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	
	import feathers.core.PopUpManager;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import utils.Fonts;
	import utils.ProfilePic;
	
	public class Hud extends Sprite
	{
		// singleton
		private static var _allowInstance:Boolean;
		private static var _instance:Hud;
		
		public static function getInstance():Hud
		{
			if (!_instance)
			{
				_allowInstance = true;
				_instance = new Hud();
				_allowInstance = false;
			}
			
			return _instance;
		}
		
		// local states
		private var _chipsContainer:Sprite;
		private var _txtChipsLabel:TextField;
		
		private var _goldContainer:Sprite;
		private var _txtGoldLabel:TextField;
		
		private var _profilePic:ProfilePic;
		
		private static var _busyContainer:Sprite;
		private static var _mcBusyIndicator:MovieClip;
		private static var _imgBusyBg:Image;
		
		public function Hud()
		{
			super();
			
			if (!_allowInstance)
				throw new Error("Cannot instantiate this class via new, use getInstance instead!");
			
			initContainers();
			
			//_profilePic = new ProfilePic(SFSInterface.getInstance().userInfo.avatarId);
			
			ProxySignals.getInstance().updateuseraccountSignal.add(updateUserAccount);
		}
		
		override public function dispose():void
		{
			_txtChipsLabel.removeFromParent(true);
			_chipsContainer.removeFromParent(true);
			
			_txtGoldLabel.removeFromParent(true);
			_goldContainer.removeFromParent(true);
			
			if(_profilePic) _profilePic.removeFromParent(true);
			
			super.dispose();
		}
		
		private function initContainers():void
		{
			// chips
			var texture:Texture = MangoAssetManager.I.getTexture("chips_indicator");
			var chipsIcon:Image = new Image(texture);
			var tf:TextFormat	= new TextFormat(Fonts.DEFAULT_FONT, Fonts.getInstance().mediumFont, Color.WHITE);
			_txtChipsLabel = new TextField(1, 1, "0", tf);
			_txtChipsLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtChipsLabel.x = 35;
			_txtChipsLabel.y = 10;
			
			_chipsContainer = new Sprite();
			_chipsContainer.addChild(chipsIcon);
			_chipsContainer.addChild(_txtChipsLabel);
			addChild(_chipsContainer);
			
			// gold
			texture = MangoAssetManager.I.getTexture("gold_indicator");
			var goldIcon:Image = new Image(texture);
			_txtGoldLabel = new TextField(1, 1, "0", tf);
			_txtGoldLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtGoldLabel.x = 40;
			_txtGoldLabel.y = 10;
			
			_goldContainer = new Sprite();
			_goldContainer.addChild(goldIcon);
			_goldContainer.addChild(_txtGoldLabel);
			addChild(_goldContainer);
		}
		
		private function updateUserAccount(chips:Number, gold:int):void
		{
			// update chips
			SFSInterface.getInstance().userInfo.chips = chips;
			_txtChipsLabel.text = getMoneyString(chips);
			
			// update gold
			SFSInterface.getInstance().userInfo.gold = gold;
			_txtGoldLabel.text = gold.toString();
		}
		
		public function attachTo(container:Sprite):void
		{
			return; // TEMP
			container.addChild(this);
			
			// position
			_chipsContainer.x = Constants.TARGET_WIDTH - _chipsContainer.width - 20;
			_chipsContainer.y = 10;
			
			_goldContainer.x = _chipsContainer.x - _goldContainer.width - 20;
			_goldContainer.y = 10;
		}
		
		public function detach():void
		{
			if (parent)
				parent.removeChild(this);
		}
		
		public function setGold(value:int):void
		{
			SFSInterface.getInstance().userInfo.gold = value;
			_txtGoldLabel.text = value.toString();
		}
		
		public function putSoundIcon():void
		{
			var buttonOn:Button = new Button(MangoAssetManager.I.getTexture("sound_btn"));
			var buttonOff:Button = new Button(MangoAssetManager.I.getTexture("no_sound_btn"));
			buttonOn.addEventListener(starling.events.Event.TRIGGERED, toggleSound);
			buttonOff.addEventListener(starling.events.Event.TRIGGERED, toggleSound);
			
			buttonOn.scaleX = buttonOff.scaleX = 0.7;
			buttonOn.scaleY = buttonOff.scaleY = 0.7;
			buttonOn.x = buttonOff.x = 20;
			buttonOn.y = buttonOff.y = 180;
			
			if (SoundDirector.getInstance().isMuted)
			{
				Starling.current.stage.removeChild(buttonOn);
				Starling.current.stage.addChild(buttonOff);
			}
			else
			{
				Starling.current.stage.removeChild(buttonOff);
				Starling.current.stage.addChild(buttonOn);
			}
			
			function toggleSound():void
			{
				if (SoundDirector.getInstance().isMuted)
				{
					SoundDirector.getInstance().muteAll(false);
					Starling.current.stage.removeChild(buttonOff);
					Starling.current.stage.addChild(buttonOn);
				}
				else
				{
					SoundDirector.getInstance().muteAll(true);
					Starling.current.stage.removeChild(buttonOn);
					Starling.current.stage.addChild(buttonOff);
				}
			}
		}
		
		public function get profilePic():ProfilePic { return _profilePic; }
		
		private static function initBusyIndicator():void
		{
			_mcBusyIndicator = getBusyIndicator(false);
			_imgBusyBg = new Image(Texture.fromColor(Constants.TARGET_WIDTH, Constants.TARGET_HEIGHT, 0x0)); // grayed out background
			_imgBusyBg.alpha = 0.5;
			_busyContainer = new Sprite();
			_busyContainer.addChild(_imgBusyBg);
			_busyContainer.addChild(_mcBusyIndicator);
		}
		
		public static function showBusyIndicator(popUpRoot:Sprite):void
		{
			if (!_busyContainer)
				initBusyIndicator();
			
			PopUpManager.root = popUpRoot ? popUpRoot : Starling.current.stage;
			PopUpManager.addPopUp(_busyContainer);
			_mcBusyIndicator.x = (Constants.TARGET_WIDTH - _mcBusyIndicator.width) / 2;
			_mcBusyIndicator.y = (Constants.TARGET_HEIGHT - _mcBusyIndicator.height) / 2;
			
			Starling.juggler.add(_mcBusyIndicator);
		}
		
		public static function hideBusyIndicator():void
		{
			Starling.juggler.remove(_mcBusyIndicator);
			
			if (PopUpManager.isPopUp(_busyContainer))
				PopUpManager.removePopUp(_busyContainer);
		}
		
		public static function getBusyIndicator(animate:Boolean = true):MovieClip
		{
			var mc:MovieClip = new MovieClip(MangoAssetManager.I.getTextures("circleloading"), 60);
			if (animate)
				Starling.juggler.add(mc); // FIXME: check for dispose
			return mc;
		}
		
		public static function clearNativeStage():void
		{
			Starling.current.nativeStage.removeChildren();
		}
		
		public static function getMoneyString(money:Number):String
		{
			var formattedMoney:String = "";
			//trace(money);
			/*if(money >= 100000000000000)
			{
			money /= 100000000000000;
			return money.toString() + " Tn.";
			}*/
			if(money >= 100000000000)
			{
				money /= 1000000000;
				formattedMoney = (uint)(money).toString();
				if(formattedMoney.length > 3)
					formattedMoney =  formattedMoney.substring(0, formattedMoney.length - 3) + "," + formattedMoney.substring(formattedMoney.length - 3, formattedMoney.length);
				return formattedMoney  + " Bn.";
			}
			if(money >= 100000000)
			{
				money /= 1000000;
				formattedMoney =(uint)(money).toString();
				if(formattedMoney.length > 3)
					formattedMoney =  formattedMoney.substring(0, formattedMoney.length - 3) + "," +  formattedMoney.substring(formattedMoney.length - 3, formattedMoney.length);
				return formattedMoney + " Mn.";
			}
			if(money >= 100000)
			{
				money /= 1000;
				formattedMoney = (uint)(money).toString();
				if(formattedMoney.length > 3)
					formattedMoney =  formattedMoney.substring(0, formattedMoney.length - 3) + "," +  formattedMoney.substring(formattedMoney.length - 3, formattedMoney.length);
				return formattedMoney + " K";
			}
			
			formattedMoney = (uint)(money).toString();
			if(formattedMoney.length > 3)
				formattedMoney =  formattedMoney.substring(0, formattedMoney.length - 3) + "," +  formattedMoney.substring(formattedMoney.length - 3, formattedMoney.length);
			return formattedMoney;
		}
	}
}