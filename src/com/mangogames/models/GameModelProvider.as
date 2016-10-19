package com.mangogames.models
{
	import com.creativebottle.starlingmvc.beans.BeanProvider;
	import com.mangogames.controls.NavigationController;
	import com.mangogames.views.mediators.LoadingScreenMediator;
	import com.mangogames.views.mediators.LobbyScreenMediator;
	import com.mangogames.views.mediators.LoginScreenMediator;
	
	/**
	 * @author Raju.M
	 */	
	public class GameModelProvider extends BeanProvider
	{
		/**
		 * registering beans here 
		 */		
		public function GameModelProvider()
		{
			beans = 
			[
				new NavigationController(),
				new LoadingScreenMediator(),
				new LoginScreenMediator(),
				new LobbyScreenMediator()
				
			];
		}
		
		
	}
}