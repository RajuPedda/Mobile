package
{
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.AbstractBaseView;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import feathers.utils.ScreenDensityScaleFactorManager;
	
	import game.Main;
	
	import starling.core.Starling;
	import starling.events.ResizeEvent;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import utils.ScaleUtils;
	
	[SWF(width="960",height="640",frameRate="60",backgroundColor="#4a4137")]
	public class Ace2Jak extends Sprite
	{
		public function Ace2Jak()
		{
			ProxySignals.getInstance().changeAspectRatioSignal.add(OnChangedAspectRatio);
			
			if(this.stage)
			{
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.align = StageAlign.TOP_LEFT;
			}
			ScaleUtils.calculateBestScaleFactor(stage);
			this.mouseEnabled = this.mouseChildren = false;
			// this will be used for IOS 
			// this.showLaunchImage();
			//this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
			init();
		}
		
		private function OnChangedAspectRatio():void
		{
			//stage.setAspectRatio(StageAspectRatio.LANDSCAPE);
			//stage.setOrientation(StageOrientation.ROTATED_RIGHT);
		}
		
		private function resizeStage(event:ResizeEvent):void
		{
			var viewPortRectangle:Rectangle = new Rectangle();
			viewPortRectangle.width = stage.stageWidth;
			viewPortRectangle.height = stage.stageHeight;
			
			Starling.current.viewPort = viewPortRectangle;
			
			/*viewPortRectangle.height = viewPortRectangle.width * 0.5625;
			if (viewPortRectangle.height > stage.stageHeight) {
			viewPortRectangle.height = stage.stageHeight;
			viewPortRectangle.width = viewPortRectangle.height / 0.5625;
			}
			
			//Centers the viewPort so you have black bars around it
			viewPortRectangle.x = (stage.stageWidth - viewPortRectangle.width) / 2;
			viewPortRectangle.y = (stage.stageHeight - viewPortRectangle.height) / 2;
			Starling.current.viewPort = viewPortRectangle;*/
		}
		
		private var _starling:Starling;
		private var _scaler:ScreenDensityScaleFactorManager;
		private var _savedAutoOrients:Boolean;
		private var _background:Loader;
		
		protected function init():void
		{
			Starling.multitouchEnabled = true;
			_starling = new Starling(Main, this.stage, null, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
			_starling.enableErrorChecking 		= Capabilities.isDebugger;
			_starling.supportHighResolutions	= true;
			_starling.skipUnchangedFrames 		= true;
			_starling.simulateMultitouch  		= false;
			_starling.showStats					= false;
			_starling.antiAliasing				= 4;
			_starling.start();
			AbstractBaseView.setStageSize();
			//_starling.showStatsAt(HAlign.LEFT, VAlign.CENTER);
			Starling.current.stage.addEventListener(ResizeEvent.RESIZE, resizeStage);
			this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
			
			//lobbyScreenItem.setScreenIDForPushEvent("screen2Signal", "screen2");
			
		}
		
		
		private function stage_deactivateHandler(event:Event):void
		{
			this._starling.stop(true);
			this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
		}
		
		private function stage_activateHandler(event:Event):void
		{
			this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
			this._starling.start();
		}
	}
}