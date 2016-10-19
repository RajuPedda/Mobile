package com.mangogames.managers
{
	import com.mangogames.models.UserInfo;
	import com.mangogames.services.SFSInterface;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.Security;
	
	
	
	import logger.Logger;
	
	import utils.Ace2JakTheme;
	
	
	
	public class ConfigManager
	{
		/**
		 * FIXME: ACTING NETWORK-MANAGER
		 */
		
		// flags
		public static const USE_DEV:Boolean = false;
		public static const USE_LOCAL_ASSETS:Boolean = false;
		
		public const SERVER_IP:String	= Constants.TEST;
		private var ASSETS_PATH:String;

		
		public var buyInAmount:int;
		
		// --- SINGLETON ---
		private static var _allowInstance:Boolean;
		private static var _instance:ConfigManager;
		
		public static function init():void
		{
			_allowInstance = true;
			_instance = new ConfigManager();
			_allowInstance = false;
		}
		
		public static function get I():ConfigManager { return _instance; }
		// --- END SINGLETON ---
		
		private var _isSoundOn:Boolean;
		private var _isTutorial:Boolean;
		private var _isChatBubbleOn:Boolean;
		private var _language:String;
		
		// misc
		private var _currentTheme:Object;
		private var _lobbySettingList:Array;
		private var _successCallback:Function;
		
		public function ConfigManager() 
		{
			_isSoundOn = true;
			_isTutorial = false;
			_isChatBubbleOn = true;
			_language = "eng";
			
			// TODO: read it from some saved location or server
		}
		
		public function processFlashvars(params:*):void
		{
			var mangorandmizer:String = params.lakfJas;
			var randomango:String = params.fJaskal;
			
			var serviceUrl:String;
			var assetsPath:String;
			
			if(SERVER_IP == Constants.TEST)
			{
				serviceUrl	= "https://test.ace2jak.com/";
				ASSETS_PATH	= "https://testplay.ace2jak.com/game_client/";
			}
			if(SERVER_IP == Constants.TEST_TWO)
			{
				serviceUrl	= "https://testtwo.ace2jak.com/";
				ASSETS_PATH	= "https://testtwoplay.ace2jak.com/game_client/";
			}
			else if (SERVER_IP == Constants.PRODUCTION_IP)
			{
				serviceUrl	="https://www.ace2jak.com/";
				ASSETS_PATH	= "https://play.ace2jak.com/game_client/";
			}
			else if (SERVER_IP == Constants.DEV)
			{
				serviceUrl	="https://dev.ace2jak.com/";
				ASSETS_PATH	= "https://devplay.ace2jak.com/game_client/";
			}
			else if (SERVER_IP == Constants.DEV_TWO)
			{
				serviceUrl	="https://devtwo.ace2jak.com/";
				ASSETS_PATH	= "https://devtwoplay.ace2jak.com/game_client/";
			}
			
			// Deploy change
			//var serviceUrl:String = "http://www.ace2jakmails.com/";//"http://www.ace2jakmails.com/";//;//params.website;
			//Security.allowDomain("*");
			Security.loadPolicyFile("crossdomain.xml");
			
			if (params.lakfJas == undefined)
			{
				// dummy data
				serviceUrl = "http://www.ace2jak.com/authentications/playr?mangorandmizer=BAhJIiU4ZDhlZTFhNTJmMzM5NTY3ZDc1Mjc0MWE1NzU2OTIwMwY6BkVU--3e14c16893624a2da8ae7700acc639a415bbcfb2&randomango=BAhJIgk1MDEyBjoGRUY=--5986056603f4923879ddb9fa7a2fa36bc7d481a6";
			}
			else
			{
				// for testing overriding the values of username and pass
				//	params.lakfJas	= "BAhJIiVlNGZiYjZkOTdiMThlNTAxMDJmZjNjMzAxMzQ4YTI4OAY6BkVU--ed9084557e91284dac2a17e505d074214e76ccfb";
				//	params.fJaskal	= "BAhJIgk1MjQ2BjoGRUY=--184a9912b559814cd743fa051fb9a2d738644428";
				
				serviceUrl += "authentications/playr?mangorandmizer=" + params.lakfJas + "&randomango=" + params.fJaskal;
			}
			
			var request:URLRequest = new URLRequest(serviceUrl);
			request.method = URLRequestMethod.GET;
			
			var loader:URLLoader = new URLLoader(request);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onServiceResponse);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onServiceError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onServiceSecurityError);
			
			function onServiceResponse(event:Event):void
			{
				var params:Object = JSON.parse(event.target.data);
				initSFS(params);
			}
			
			function onServiceError(event:IOErrorEvent):void
			{
				Logger.log(event.toString());
			}
			
			function onServiceSecurityError(event:SecurityError):void
			{
				Logger.log(event.message);
			}
		}
		
		private function initSFS(params:*):void
		{
			if (params.status != undefined && params.status != "ok")
			{
				Logger.log("authentication failed!");
				Logger.log("reason: " + params.reason + " [" + params.code + "]");
				return;
			}
			
			Logger.log("processing flashvars...");
			// just small hack
			params.gender	= 0;
			
			var userInfo:UserInfo = new UserInfo(
				params.user_id != undefined ? params.user_id : 5022,
				params.first_name != undefined ? params.first_name : "test6",
				params.chips != undefined ? params.chips : 30000,
				params.gold != undefined ? params.gold : 999,
				params.gender!= undefined?params.gender:1);
				//params.icon	!= undefined?params.icon: "http://"+SERVER_IP+"/game_client/profiles/male1.jpg"); //http://"+SettingsManager.I.SERVER_IP+"/game_client/profiles/
			
			const devServer:String = "ec2-52-74-144-219.ap-southeast-1.compute.amazonaws.com";
			const mainServer:String = SERVER_IP ;//"104.238.81.49";
			
			var sfsHost:String = (params.host != undefined) ? params.host : (USE_DEV ? devServer : mainServer);
			var sfsPort:int = (params.port != undefined) ? int(params.port) : 9933;
			var sfsHTTPPort:int = (params.httpPort != undefined) ? int(params.httpPort) : 8080;
			var sfsZone:String = (params.zone != undefined) ? params.zone : "Rummy";
			var sfsDebug:Boolean = (params.debug != undefined) ? params.debug : true;
			SFSInterface.getInstance().initSFSConnection(sfsHost, sfsPort, sfsHTTPPort, sfsZone, sfsDebug, userInfo);
			
			Constants.assetPathPrefix = (params.assetPathPrefix != undefined) ? params.assetPathPrefix : 
				(USE_LOCAL_ASSETS ? "" : (USE_DEV ? "http://"+SERVER_IP+"/game_client/" : ASSETS_PATH));
		}
		
		public function setCurrentTheme():void
		{
			_currentTheme = new Ace2JakTheme();
		}
		
		public function get currentTheme():Object { return _currentTheme; }
		public function get language():String { return _language; }
		public function get isChatBubbleOn():Boolean { return _isChatBubbleOn; }
		public function set isChatBubbleOn(value:Boolean):void { _isChatBubbleOn = value; }
		public function get isTutorial():Boolean { return _isTutorial; }
		public function set isTutorial(value:Boolean):void { _isTutorial = value; }
		public function get isSoundOn():Boolean { return _isSoundOn; }
		public function set isSoundOn(value:Boolean):void { _isSoundOn = value; }
		public function get lobbySettingList():Array { return _lobbySettingList; }
		public function set lobbySettingList(value:Array):void { _lobbySettingList = value; }
	}
}