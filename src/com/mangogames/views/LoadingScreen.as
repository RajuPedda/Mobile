package com.mangogames.views
{
	
	import flash.system.System;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import utils.Fonts;
	import utils.ProgressBar;
	
	public class LoadingScreen extends Sprite
	{
		private var _loadingProgress:ProgressBar;
		private var _loadingText:TextField;
		private var loader:Image;
		
		[Embed(source="../../../../src/assets/embed/splash.jpg")]
		public static const Splash:Class;
		
		public function LoadingScreen()
		{
			super();
		}
		
		private function initUI():void
		{
			var imgTexture:Texture	= Texture.fromEmbeddedAsset(Splash);//Texture.fromBitmap(new MangoAssetManager.Splash(), false);
			loader	= new Image(imgTexture);
			loader.width			= Starling.current.stage.stageWidth;
			loader.height			= Starling.current.stage.stageHeight;
			addChild(loader);
			
			_loadingProgress = new ProgressBar(459, 15, false);
			_loadingProgress.x = 253;
			_loadingProgress.y = 418;
			_loadingProgress.changeColour(0xF68020);
			addChild(_loadingProgress);
			
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, 18, Color.WHITE);
			_loadingText = new TextField(1, 1, "", tf);
			_loadingText.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_loadingText.alignPivot("center");
			_loadingText.x = 300;
			_loadingText.y = 400;	
			//addChild(_loadingText);
		}
		
		[PostConstruct]
		public function postConstruct():void
		{
			initUI();
		}
		
		[PreDestroy]
		public function preDestroy():void
		{
			loader.removeFromParent(true);
			loader	= null;
			_loadingProgress.removeFromParent(true);
			_loadingProgress	= null;
		}
		
		
		override public function dispose():void
		{
			removeChildren(0, -1, true);
		}
		
		public function updateLoadProgress(progress:Number):void
		{
			var progressPercent:int = progress * 100;
			_loadingText.text = "Loading " + progressPercent.toString() + "%";
			_loadingProgress.ratio = progress;
			if(progress == 1)
			{
				System.pauseForGCIfCollectionImminent(0);
				System.gc();
			}
		}
	}
}