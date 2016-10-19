package com.mangogames.views.mediators
{
	import com.creativebottle.starlingmvc.events.EventMap;
	import com.mangogames.views.lobby.LobbyScreenView;
	import com.mangogames.views.login.LoginScreenView;
	
	import flash.desktop.NativeApplication;
	
	import starling.events.Event;
	
	
	public class LoginScreenMediator extends AbstractBaseMediator
	{
		private var _eventMap:EventMap = new EventMap();
		
		[ViewAdded]
		public function viewAdded(view:LoginScreenView):void
		{
			super.postConstruct(view);
			
			_eventMap.addMap(LoginScreenView(view).loginBtn, Event.TRIGGERED, onLoginBtnClickHandler);
			_eventMap.addMap(LoginScreenView(view).signUpBtn, Event.TRIGGERED, onSignUpBtnClickHandler);
			
			//ProxySignals.getInstance().loginResultSignal.add(onLoginResult);
		}
		
		
		private function onSignUpBtnClickHandler():void
		{
			LoginScreenView(_view).showSignUpPopup(showLobbyScreen);
		}
		
		private function onLoginBtnClickHandler():void
		{
			LoginScreenView(_view).onLoginClickHandler(onLoginResult);
		}
		
		private function showLobbyScreen():void
		{
			changeDeviceAspectRatio();
			transitionView(LobbyScreenView);
		}
		
		[ViewRemoved]
		public function viewRemoved(view:LoginScreenView):void
		{
			cleanup();
			
			_eventMap.removeAllMappedEvents();
			_view = null;
			
			//ProxySignals.getInstance().loginResultSignal.remove(onLoginResult);
			
			//SettingsManager.I.hideBusyIndicator();
		}
		
		
		private function onLoginResult(success:Boolean):void
		{
			toggleButtonEnable(true);
			//SettingsManager.I.hideBusyIndicator();
			
			if (success)
			{
				changeDeviceAspectRatio();
				//transitionView(LobbyScreenView);
				LoginScreenView(_view).initScreens();
			}
			else
			{
				//PopUpManager.addPopUp(new InformationPopup("Login Failed!"));
			}
		}
		
		private function toggleButtonEnable(value:Boolean):void
		{
			if(LoginScreenView(_view)) LoginScreenView(_view).loginBtn.enabled = value;
			if(LoginScreenView(_view)) LoginScreenView(_view).signUpBtn.enabled = value
			//_view.btnLoginPhonebook.enabled = value;
		}
		
		override protected function onEnterKeyHandler():void
		{
			if(LoginScreenView(_view).isValidated)
				LoginScreenView(_view).onLoginClickHandler(onLoginResult);
		}
		
		override protected function onExit():void
		{
			// no need of confirmation here
			NativeApplication.nativeApplication.exit();
		}
	}
}