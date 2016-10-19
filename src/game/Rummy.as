package game
{
	import com.mangogames.audio.SoundDirector;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.popup.DisconnectionPopup;
	
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import feathers.core.IPopUpManager;
	import feathers.core.PopUpManager;
	
	import starling.core.Starling;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	
	import utils.MangoPopUpManager;
	
	public class Rummy
	{
		private var _disconnectPopup:DisconnectionPopup;
		
		private var _starling:Starling;
		
		public function Rummy(stage:Stage)
		{
			initSplash();
			initStarling(stage);
			initListeners(stage);
		}
		
		private function initSplash():void
		{
//			var splash:Bitmap = new MangoAssetManager.Splash();
//			splash.smoothing = true;
//			splash.width = Constants.TARGET_WIDTH;
//			splash.height = Constants.TARGET_HEIGHT;
//			addChild(splash);
		}
		
		private function initStarling(stage:Stage):void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Starling.multitouchEnabled = false; // useful on mobile devices
			
			//var viewPort:Rectangle = new Rectangle(0, 0, Constants.TARGET_WIDTH, Constants.TARGET_HEIGHT);
			var viewPort:Rectangle = RectangleUtil.fit(
				new Rectangle(0, 0, Constants.TARGET_WIDTH, Constants.TARGET_HEIGHT), 
				new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 
				ScaleMode.SHOW_ALL, false);
			
			_starling = new Starling(Main, stage, viewPort);
			//_starling.antiAliasing = 1;
			_starling.enableErrorChecking = Capabilities.isDebugger;
			
			_starling.stage.stageWidth = Constants.TARGET_WIDTH;
			_starling.stage.stageHeight = Constants.TARGET_HEIGHT;
			
			_starling.stage3D.addEventListener(Event.CONTEXT3D_CREATE, function(e:Event):void 
			{
				_starling.simulateMultitouch = false;
				_starling.showStats = false;
				_starling.start();
				initAssets();
			});
			
			// show debug stats
			//_starling.showStatsAt(HAlign.LEFT, VAlign.CENTER);
			
			PopUpManager.popUpManagerFactory = function():IPopUpManager { return new MangoPopUpManager(); }
		}
		
		private function initAssets():void
		{
			//Hud.clearNativeStage();
			
			// init asset manager
		//	MangoAssetManager.init();
			MangoAssetManager.I.showLoadingScreen();
		}
		
		private function initListeners(stage:Stage):void
		{
			// listen stage activate/deactivate
			stage.addEventListener(Event.ACTIVATE, onAppActivate);
			stage.addEventListener(Event.DEACTIVATE, onAppDeactivate);
			
			// listen other signals
			ProxySignals.getInstance().disconnectionSignal.add(onDisconnectionSignal);
		}
		
		private function onAppActivate(event:Event):void
		{
			trace ("application activated!");
			//_starling.start();
		}
		
		private function onAppDeactivate(event:Event):void
		{
			trace ("application deactivated!");
			//_starling.stop();
			SoundDirector.getInstance().stopAllSounds();
		}
		
		private function onDisconnectionSignal(status:Boolean):void
		{
			if (status)
			{
				_disconnectPopup = new DisconnectionPopup();
				PopUpManager.root = Starling.current.stage;
				PopUpManager.addPopUp(_disconnectPopup);
			}
			else
			{
				if (PopUpManager.isPopUp(_disconnectPopup))
				{
					PopUpManager.removePopUp(_disconnectPopup, true);
					_disconnectPopup = null;
				}
			}
		}
	}
}