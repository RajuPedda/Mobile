package com.mangogames.views.login
{
	import com.hurlant.util.Base64;
	import com.mangogames.managers.ConfigManager;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.AbstractBaseView;
	import com.mangogames.views.lobby.LobbyScreenView;
	import com.mangogames.views.login.signUp.SignUpPopup;
	import com.mangogames.views.popup.ConfirmationPopup;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import air.net.URLMonitor;
	
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.controls.TextInput;
	import feathers.core.PopUpManager;
	import feathers.motion.Slide;
	
	import logger.Logger;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	
	import utils.ControlUtils;
	import utils.Fonts;
	import utils.ScaleType;
	import utils.ScaleUtils;

	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class LoginScreenView extends AbstractBaseView
	{
		public var loginBtn:Button;
		public var signUpBtn:Button;
		protected var userNameTf:TextInput;
		public var passwordTf:TextInput;
		private var forgotString:TextField;
		private var clickHereBtn:Button;
		private var bg:Image;
		private var loginPanelContainer:Sprite;
		private var loginPanelBg:Image;
		private var _signUpPopup:SignUpPopup;
		private var _waitingPopup:ConfirmationPopup
		
		private var _logo:Image;
		
		private const loginUrl:String 	= "https://test.ace2jak.com/authentications/login";
		private var _sfsLoginSuccessCallback:Function;
		
		
		public function LoginScreenView()
		{
			super();
			ProxySignals.getInstance().loginSuccessfulSignal.add(onSFSloginSuccess);
			ProxySignals.getInstance().gameRoomAdded.add(onGameRoomAdded);
			ProxySignals.getInstance().viewLobbySignal.add(viewLobby);
		}
		
		private function initUI():void
		{
			var bg:Image = MangoAssetManager.I.getImage("01", ScaleType.NO_BORDER);
			bg.width	 = STAGE_WIDTH;
			bg.height	 = STAGE_HEIGHT;
			addChild(bg);
			
			_logo = MangoAssetManager.I.getImage("logo_05", ScaleType.NONE);
			ScaleUtils.applyPercentageScale(_logo, 20, 20);
			addChild(_logo);
			_logo.x					= (STAGE_WIDTH - _logo.width)/2;
			_logo.y					= _logo.height/2- PADDING;
			
			loginPanelContainer		= new Sprite();
			addChild(loginPanelContainer);
			
			loginPanelBg			= MangoAssetManager.I.getImage("login_bg", ScaleType.NONE);
			ScaleUtils.applyPercentageScale(loginPanelBg, 70, 50);
			loginPanelContainer.addChild(loginPanelBg);
			
			userNameTf				= ControlUtils.createTextInput(ScaleType.NONE, 15);
			ScaleUtils.applyPercentageScale(userNameTf, 40, 10);
			userNameTf.prompt		= "  User name";
			userNameTf.styleNameList.add( "username-text-input" );
			userNameTf.text			= "RajuPedda";
			loginPanelContainer.addChild(userNameTf);
			userNameTf.textEditorProperties.fontSize	= Fonts.getInstance().largeFont*ScaleUtils.scaleFactorNoBorder;
			userNameTf.validate();
			userNameTf.x			= loginPanelBg.x+userNameTf.width/7;
			userNameTf.y			= loginPanelBg.y + userNameTf.height;
			userNameTf.showFocus();
			
			passwordTf				= ControlUtils.createTextInput(ScaleType.NONE, 15);
			passwordTf.displayAsPassword	= true;
			passwordTf.prompt		= "  Password";
			ScaleUtils.applyPercentageScale(passwordTf, 40, 10);
			passwordTf.styleNameList.add( "username-text-input" );
			passwordTf.text			= "123";
			loginPanelContainer.addChild(passwordTf);
			passwordTf.validate();
			passwordTf.x			= loginPanelBg.x+passwordTf.width/7;
			passwordTf.y			= userNameTf.y+userNameTf.height+userNameTf.height/2;
			passwordTf.showFocus();
			
			loginBtn 				= ControlUtils.createButton("login_btn", "", ScaleType.NO_BORDER);
			ScaleUtils.applyPercentageScale(loginBtn, 15, 10);
			loginBtn.x 				= loginPanelBg.width - loginBtn.width-loginBtn.width/4;
			loginBtn.y 				= (loginPanelBg.height - loginBtn.height)/2;
			loginPanelContainer.addChild(loginBtn);	
			
			forgotString			= ControlUtils.createCenteredLabel("Forgot name/password?", ScaleType.NONE);
			forgotString.format.size= 24 * ScaleUtils.scaleFactorNoBorder;
			forgotString.x			= passwordTf.x;
			forgotString.y			= passwordTf.y + (passwordTf.height+passwordTf.height/2);
			loginPanelContainer.addChild(forgotString);
			
			/*clickHereTf				= ControlUtils.createCenteredLabel("Click Here", ScaleType.NO_BORDER);
			clickHereTf.x			= forgotString.width+clickHereTf.width/2;
			clickHereTf.y			= loginPanelBg.height-(clickHereTf.height*2);
			loginPanelContainer.addChild(clickHereTf);*/
			
			clickHereBtn 			= ControlUtils.createButton("clickhere_text", "", ScaleType.NO_BORDER);
			loginPanelContainer.addChild(clickHereBtn);
			clickHereBtn.x			= passwordTf.width/2 + clickHereBtn.width*2;
			clickHereBtn.y			= forgotString.y + clickHereBtn.height/2;
			clickHereBtn.useHandCursor	= true;
			
			loginPanelContainer.x	= (STAGE_WIDTH - loginPanelContainer.width)/2;
			loginPanelContainer.y	= (STAGE_HEIGHT - loginPanelContainer.height)/2;
			
			signUpBtn 				= ControlUtils.createButton("signup_btn", "", ScaleType.NO_BORDER);
			ScaleUtils.applyPercentageScale(signUpBtn, 60, 10);
			addChild(signUpBtn);
			signUpBtn.x 			= (STAGE_WIDTH - signUpBtn.width)/2;
			signUpBtn.y 			= STAGE_HEIGHT-signUpBtn.height-6;
		}
		
		public function isValidated():Boolean
		{
			var validated:Boolean = false;
			if(userNameTf.text.length >1 && passwordTf.text.length>1)
				validated	= true;
			
			return validated;
		}
		
		private function onSFSloginSuccess():void
		{
			if(PopUpManager.isPopUp(_waitingPopup))		
				PopUpManager.removePopUp(_waitingPopup);
			
			if(PopUpManager.isPopUp(_internetConnectionPopup))		
				PopUpManager.removePopUp(_internetConnectionPopup);
			
			_sfsLoginSuccessCallback.call(true, true);
		}
		
		private var _stackScreenNavigator:StackScreenNavigator;
		private var screen1Item:StackScreenNavigatorItem;
		private var _internetConnectionPopup:ConfirmationPopup;
		
		public function initScreens():void
		{
			_stackScreenNavigator	= new StackScreenNavigator();
			_stackScreenNavigator.pushTransition = Slide.createSlideLeftTransition();
			_stackScreenNavigator.popTransition = Slide.createSlideRightTransition();
			addChild(_stackScreenNavigator);
			
			screen1Item	= new StackScreenNavigatorItem(GameScreen1);
			_stackScreenNavigator.addScreen("screen1", screen1Item);
			//screen1Item.setScreenIDForPushEvent("complete", "lobbyScreen");
			//_stackScreenNavigator.pushScreen("screen1");
			
			
			var screen2Item:StackScreenNavigatorItem	= new StackScreenNavigatorItem(GameScreen2)
			_stackScreenNavigator.addScreen("screen2", screen2Item);
			//screen1Item.setScreenIDForPushEvent("lobbyScreenSignal", "lobbyScreen");
			
			var lobbyScreenItem:StackScreenNavigatorItem	= new StackScreenNavigatorItem(LobbyScreenView)
			_stackScreenNavigator.addScreen("lobbyScreen", lobbyScreenItem);
			screen1Item.setScreenIDForPushEvent("screen1Signal", "screen1");
			_stackScreenNavigator.pushTransition
			
			_stackScreenNavigator.rootScreenID	= "lobbyScreen";
		}
		
		private function onGameRoomAdded(roomId:int, roomName:String):void
		{
			//screen1Item.properties.roomId	= roomId;
			//screen1Item.properties.roomName	= roomName;
			//_stackScreenNavigator.pushScreen("screen1");
		}
		
		private function viewLobby():void
		{
			_stackScreenNavigator.popToRootScreen();
			//_stackScreenNavigator.pushScreen("lobbyScreen");
		}
		
		protected function statusChangedHandler(event:StatusEvent):void
		{
			trace(event.target.available);
		}
		
		public function onLoginClickHandler(callback:Function):void
		{
			_waitingPopup	= new ConfirmationPopup("", "Please wait...");
			PopUpManager.addPopUp(_waitingPopup);
			
			var isAvailable:Boolean;
			
			var urlMonitor:URLMonitor	= new URLMonitor(new URLRequest("https://ace2jak.com/"));
			urlMonitor.addEventListener(StatusEvent.STATUS, function (event:StatusEvent):Boolean
			{
				isAvailable	=  event.target.available;
				if(isAvailable)
				{
					onInternetConnectionSuccess(callback);
				}
				else
				{
					onInternetConnectionFailure();
				}
				
			});
			urlMonitor.start();
		}
		
		private function onInternetConnectionFailure():void
		{
			if(PopUpManager.isPopUp(_waitingPopup))		
				PopUpManager.removePopUp(_waitingPopup);
			
			_internetConnectionPopup	= new ConfirmationPopup("No Internet Connection", "Please check your internet connection");
			PopUpManager.addPopUp(_internetConnectionPopup);
		}
		
		private function onInternetConnectionSuccess(callback:Function):void
		{
			_sfsLoginSuccessCallback	= callback;
			loginBtn.enabled 	= false;
			
			/*_waitingPopup	= new ConfirmationPopup("", "Please wait...");
			PopUpManager.addPopUp(_waitingPopup);*/
			
			var encryptedPassword:String 	= Base64.encode(passwordTf.text);//encrypt(txiPassword.text, decrKey, null);
			var url:String 					= loginUrl + "?uname=" + userNameTf.text + "&password=" + encryptedPassword;
			var request:URLRequest 			= new URLRequest(url);
			var loader:URLLoader 			= new URLLoader(request);
			
			
			loader.addEventListener(flash.events.Event.COMPLETE, onCompletePlaceHolder, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError,false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError, false, 0, true);
			loader.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError, false, 0, true);
			
			// handlers
			//	var loginPopup:LoginPopup = this;
			function onCompletePlaceHolder(event:*):void
			{
				Logger.log("request successfully performed!");
				var params:* = JSON.parse(event.target.data);
				if (params.status == "ok" && params.lakfJas != undefined)
				{
					// done with the game server login , now need to login with the Smartfox server login as well
					// so we will initiate the smartfox server with the required parameters
					ConfigManager.I.processFlashvars(params);
					
					//PopUpManager.removePopUp(loginPopup);
					//callback(params);
					
				}
				else
				{
					callback.call(true,false);
				}
			}
			
			function onError(event:ErrorEvent):void
			{
				Logger.log("IOError " + event.errorID + "Error = "+ event.text);
			}
		}
		
		public function showSignUpPopup(callback:Function):void
		{
			if(_signUpPopup)
			{
				var isAllDone:Boolean	= _signUpPopup.isAllValuesEnteredInTheRequiredFields();
				if(isAllDone)
				{
					signUpBtn.enabled	= false;
					_signUpPopup.showEnterPasswordBox(callback);		
				}
			}
			else
			{
				//_logo.y	-= _logo.height/3;
				loginPanelContainer.visible	= false;
				_signUpPopup	= new SignUpPopup(STAGE_WIDTH, STAGE_HEIGHT);
				_signUpPopup.y	+= 20; 
				addChildAt(_signUpPopup, this.numChildren-1);
			}
		}
		
		[PostConstruct]
		public function postConstruct():void
		{
			initUI();
		}
		
		[PreDestroy]
		public function preDestroy():void
		{
			cleanUp();
		}
		
		private function cleanUp():void
		{
			
		}
		
		
	}
}