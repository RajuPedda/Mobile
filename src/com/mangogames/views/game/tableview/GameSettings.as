package com.mangogames.views.game.tableview
{
	import com.mangogames.audio.SoundDirector;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.views.game.AvatarsPopup;
	import com.mangogames.views.popup.ConfirmationPopup;
	
	import feathers.controls.Label;
	import feathers.controls.ToggleSwitch;
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import utils.ScaleUtils;
	
	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class GameSettings extends Sprite
	{
		public function GameSettings(tableVw:TableView, leaveTableCallback:Function)
		{
			super();
			
			_tableVw			= tableVw;
			_leaveTableCallback	= leaveTableCallback;
			init();
		}
		
		private var _tableVw:TableView;
		private var _avatarBtn:Button;
		private var settingsBtn:Button;
		private var _avatarPopup:AvatarsPopup;
		private var _isAvatarBtnShowing:Boolean;
		private var _settingsContainer:Sprite;
		private var _btnLeave:Button;
		private var _leavePopup:ConfirmationPopup;
		private var _soundToggleBtn:ToggleSwitch;
		private var _leaveTableCallback:Function;
		private var _vibrationBtn:ToggleSwitch;
		private var _soundLabel:Label;
		private var _vibrationLabel:Label;
		
		
		private function init():void
		{
			var bg:Quad	= new Quad(100, 100, 0x4a4137);
			ScaleUtils.applyPercentageScale(bg, 19, 31);
			bg.x	= (width- bg.width)/2;
			bg.y	= 40;
			addChild(bg);
			
			_avatarBtn	= new Button(MangoAssetManager.I.getTexture("avatars_btn"));
			ScaleUtils.applyPercentageScale(_avatarBtn, 11, 6);
			_avatarBtn.x	= bg.x + (bg.width - _avatarBtn.width)/2;
			_avatarBtn.y	= 50;
			addChild(_avatarBtn);
			_avatarBtn.addEventListener(Event.TRIGGERED, onAvatarsBtnClick);
			
			_btnLeave = new Button(MangoAssetManager.I.getTexture("leavetable_btn_02"));
			ScaleUtils.applyPercentageScale(_btnLeave, 11, 6);
			_btnLeave.x	= bg.x + (bg.width - _btnLeave.width)/2;
			_btnLeave.y	= _avatarBtn.y+_btnLeave.height+5;
			addChild(_btnLeave);
			_btnLeave.textFormat.size = 14;
			_btnLeave.addEventListener(Event.TRIGGERED, onLeaveTable);
			
			// sound label
			_soundLabel	= new Label();
			_soundLabel.text	= "Sound";
			addChild(_soundLabel);
			_soundLabel.styleNameList.add("settings-label");
			_soundLabel.validate();
			_soundLabel.x	= bg.x + 5;
			
			_soundToggleBtn	= new ToggleSwitch();
			ScaleUtils.applyPercentageScale(_soundToggleBtn, 11, 6);
			addChild(_soundToggleBtn);
			_soundToggleBtn.validate();
			_soundToggleBtn.x	= _soundLabel.x + _soundLabel.width+5;
			_soundToggleBtn.y	= _btnLeave.y+_soundToggleBtn.height+5;
			_soundToggleBtn.addEventListener(Event.CHANGE, soundBtnChangeHandler);
			
			
			_soundLabel.y	= _soundToggleBtn.y+ (_soundToggleBtn.height - _soundLabel.height)/2;
			
			_vibrationLabel	= new Label();
			_vibrationLabel.text	= "Vibration";
			_vibrationLabel.styleNameList.add("settings-label");
			addChild(_vibrationLabel);
			_vibrationLabel.validate();
			_vibrationLabel.x	= bg.x +5;
			
			_vibrationBtn	= new ToggleSwitch();
			ScaleUtils.applyPercentageScale(_vibrationBtn, 11, 6);
			addChild(_vibrationBtn);
			_vibrationBtn.validate();
			_vibrationBtn.x	= _vibrationLabel.x + _vibrationLabel.width + 5;
			_vibrationBtn.y	= _soundToggleBtn.y+_vibrationBtn.height+5;
			_vibrationBtn.addEventListener(Event.CHANGE, soundBtnChangeHandler);
			
			_vibrationLabel.y	= _vibrationBtn.y+ (_vibrationBtn.height - _vibrationLabel.height)/2;
		}
		
		private function onAvatarsBtnClick():void
		{
			_avatarPopup	= new AvatarsPopup(onAvatarPopupClosed);
			PopUpManager.addPopUp(_avatarPopup);
		}
		
		private function onAvatarPopupClosed(isSelected:Boolean):void
		{
			if(isSelected)
			{
				var seatVw:SeatView			= _tableVw.getSeatBySeatId(_tableVw._mySeatId);
				seatVw.initAvatar(SFSInterface.getInstance().userInfo.avatarId);
			}
			this.visible	= this.visible?false:true;
		}
		
		private function soundBtnChangeHandler(event:Event):void
		{
			trace("toggle switch changed:", _soundToggleBtn.isSelected);
			if (_soundToggleBtn.isSelected)
			{
				SoundDirector.getInstance().muteAll(false);
			}
			else
			{
				SoundDirector.getInstance().muteAll(true);
			}
		}
		
		private function onLeaveTable(event:Event):void
		{
			_leaveTableCallback.call(true, event);
		}
		
	}
}