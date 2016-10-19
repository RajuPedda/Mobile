package com.mangogames.views.mediators
{
	import com.mangogames.events.NavigationEvent;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.login.LoginScreenView;
	import com.mangogames.views.popup.DisconnectionPopup;
	
	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import feathers.core.PopUpManager;
	
	import starling.display.Sprite;
	import starling.events.EventDispatcher;
	
	
	public class AbstractBaseMediator
	{
		[Dispatcher]
		public var Dispatcher:EventDispatcher;
		
		protected var _view:Sprite;
		
		private var _disconnectPopup:DisconnectionPopup;
		
		public function AbstractBaseMediator()
		{
		}
		
		public function changeDeviceAspectRatio():void
		{
			ProxySignals.getInstance().changeAspectRatioSignal.dispatch();
		}
		
		public function postConstruct(view:Sprite):void
		{
			_view = view;
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			ProxySignals.getInstance().disconnectionSignal.add(onDisconnectionSignal);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.BACK || event.keyCode == Keyboard.ESCAPE)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				
				// try to close any popup which is on screen, otherwise continue with view's default behaviour
				/*var popupManager:MangoPopUpManager = MangoPopUpManager(PopUpManager.forStarling(Starling.current));
				
				if (popupManager.topMostPopup is DisconnectionPopup)
					onExit();
				else if (popupManager.hasPopUps)
					popupManager.closeTopMostPopup();
				else
					onExit();*/
			}
			else if(event.keyCode == Keyboard.HOME)
			{
				// handle the button press here.
			}
			else if(event.keyCode == Keyboard.MENU)
			{
				// handle the button press here.
			}
			else if(event.keyCode == Keyboard.ENTER)
			{
				onEnterKeyHandler();
			}
		}
		
		protected function onEnterKeyHandler():void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function onDisconnectionSignal(status:Boolean):void
		{
			if (_view && _view is LoginScreenView)
				return;
			
			if (status)
			{
				_disconnectPopup = new DisconnectionPopup();
				PopUpManager.addPopUp(_disconnectPopup);
			}
			else
			{
				if(PopUpManager.isPopUp(_disconnectPopup))
				{
					PopUpManager.removePopUp(_disconnectPopup, true);
					_disconnectPopup = null;
				}
			}
		}
		
		protected function onExit():void
		{
			// nothing to do here, override this in child
		}
		
		protected function transitionView(view:Class):void
		{
			Dispatcher.dispatchEventWith(NavigationEvent.CHANGE_VIEW, false, view);
		}
		
		protected function cleanup():void
		{
			ProxySignals.getInstance().disconnectionSignal.remove(onDisconnectionSignal);
			NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
	}
}