package com.mangogames.views.lobby
{
	import com.mangogames.views.login.signUp.ChangePassword;
	import com.mangogames.views.popup.ConfirmationPopup;
	
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import utils.ControlUtils;
	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class LobbySettings extends Sprite
	{
		
		public function LobbySettings(logOutCallback:Function)
		{
			super();
			_logOutConfirmationCallback	= logOutCallback;
			init();
		}
		
		
		private var _version:Button;
		private var _sounds:Button;
		private var _changePass:Button;
		private var _logOut:Button;
		private var _logOutConfirmationPopup:ConfirmationPopup;
		private var changePass:ChangePassword;
		
		private var _logOutConfirmationCallback:Function;
		
		private function init():void
		{
/*			_version 		= ControlUtils.createButton("version", "");
		//	addChild(_version);
		//	_version.x		= _version.width/6;
			_version.y		= _version.height*-1;
*/			
			_sounds 		= ControlUtils.createButton("sounds", "");
			addChild(_sounds);
			_sounds.y		= _sounds.height*-1;
			
			_changePass 		= ControlUtils.createButton("change_password", "");
			addChild(_changePass);
			_changePass.x		= _sounds.x;
			_changePass.y		= _sounds.height*-2.1;
			_changePass.addEventListener(Event.TRIGGERED, onChangePassClickHandler);
			
			_logOut 		= ControlUtils.createButton("logout_btn", "");
			addChild(_logOut);
			_logOut.x		= _sounds.x;
			_logOut.y		= _sounds.height*-3.2;
			_logOut.addEventListener(Event.TRIGGERED, onLogOutClickHandler);
		}
		
		private function onChangePassClickHandler():void
		{
			changePass	= new ChangePassword(onSubmittedPassChange);
			PopUpManager.addPopUp(changePass);
		}
		
		private function onSubmittedPassChange():void
		{
			if(PopUpManager.isPopUp(changePass))
				PopUpManager.removePopUp(changePass);
		}
		
		private function onLogOutClickHandler():void
		{
			_logOutConfirmationPopup	= new ConfirmationPopup("LOG OUT", "Are you sure you want to log out from the game", onOkCallback, onCancel);
			PopUpManager.addPopUp(_logOutConfirmationPopup);
		}
		
		private function onOkCallback():void
		{
			removePopup();
			_logOutConfirmationCallback.call();
		}
		
		private function removePopup():void
		{
			PopUpManager.removePopUp(_logOutConfirmationPopup);
			_logOutConfirmationPopup	= null;
		}
		
		private function onCancel():void
		{
			removePopup();
		}
	}
}