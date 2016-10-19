package com.mangogames.views.mediators
{
	
	
	import com.mangogames.managers.ConfigManager;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.views.LoadingScreen;
	import com.mangogames.views.login.LoginScreenView;
	
	
	public class LoadingScreenMediator extends AbstractBaseMediator
	{
		public function LoadingScreenMediator()
		{
			super();
		}
		
		[ViewAdded]
		public function viewAdded(view:LoadingScreen):void
		{
			super.postConstruct(view);
			MangoAssetManager.I.initManifest(onAssetsLoaded);
		}
		
		private function onAssetsLoaded():void
		{
			ConfigManager.init();
			ConfigManager.I.setCurrentTheme();
			transitionView(LoginScreenView)
		}
		
		[ViewRemoved]
		public function viewRemoved(view:LoadingScreen):void
		{
			cleanup();
			_view = null;
		}
		
		
		
		
		/*private function checkPreviousLogin():void
		{
			Constants.loginOption = SettingsManager.I.localStorage.loggedInAs;
			switch (Constants.loginOption)
			{
				case Constants.FB_LOGIN_OPTION:
					ProxySignals.getInstance().loginResultSignal.add(onLoginResult);
					NetworkManager.I.initFBLogin();
					break;
				
				case Constants.GUEST_LOGIN_OPTION:
					ProxySignals.getInstance().loginResultSignal.add(onLoginResult);
					NetworkManager.I.initGuestLogin(SettingsManager.I.localStorage.externalId, SettingsManager.I.localStorage.name);
					break;
				
				default:
					transitionView(LoginScreenView);
					break;
			}
		}
		
		private function onLoginResult(success:Boolean):void
		{
			ProxySignals.getInstance().loginResultSignal.remove(onLoginResult);
			SettingsManager.I.hideBusyIndicator();
			
			if (success)
			{
				transitionView(LobbyView);
			}
			else
			{
				transitionView(LoginScreenView);
				PopUpManager.addPopUp(new InformationPopup("Failed to continue using last login details!"));
			}
		}*/
	}
}