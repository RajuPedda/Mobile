package com.mangogames.managers
{
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.LoadingScreen;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	
	import logger.Logger;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.EventDispatcher;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	import utils.Fonts;
	import utils.ScaleType;
	import utils.ScaleUtils;
	
	public class MangoAssetManager extends EventDispatcher
	{
		// --- SINGLETON ---
		private static var _allowInstance:Boolean = false;
		private static var _instance:MangoAssetManager;
		
		public static function get I():MangoAssetManager 
		{ 
			_instance ||= new MangoAssetManager(new InternalLocker());
			return _instance;
		}
		// --- END SINGLETON ---
		
		// embedded assets
		[Embed(source="../../../../src/assets/embed/ace2jak_preloader.jpg")] public static const PreloaderScreen:Class;
		[Embed(source="../../../../src/assets/embed/ace2jak_loader.jpg")] public static const LoaderScreen:Class;
		[Embed(source="../../../../src/assets/embed/splash.jpg")] public static const Splash:Class;
		
		// consts
		private const ASSET_LOCATION:String = "assets";
		private const MANIFEST_LOCATION:String = ASSET_LOCATION + "/manifest.xml";
		
		// data driven
		private var _imageLocation:String 		= "images";
		private var _themeLocation:String 		= "defaultTheme";
		private var _audioLocation:String 		= "audio";
		private var _positionLocation:String 	= "positions";
		private var _dataLocation:String 		= "data"; // getting game data
		private var _fontsLocation:String 		= "fonts";
		
		// stats
		private var _xmlsToLoad:int;
		private var _xmlsLoaded:int;
		private var _mainElements:XML;
		private var _gameElements:XML;
		private var _gameData:XML;
		private var _gameRules:XML;
		private var _assetManager:AssetManager; // starling's asset manager
		
		// progress cosmetics
		private var _loadingScreen:LoadingScreen;
		
		private var _manifestLoadedCallback:Function;
		
		public function MangoAssetManager(ic:InternalLocker)
		{
			if(ic == null)
			{
				throw new Error("Cannot create instance of singleton class MangoAssetManager, use I() instead");
			}
			
			_assetManager = new AssetManager();
			_assetManager.verbose = false;
			
			//initManifest();
		}
		
		public function initManifest(callback:Function):void
		{
			_manifestLoadedCallback	= callback;
			var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest(Constants.assetPathPrefix + MANIFEST_LOCATION));
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onManifestLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onManifestLoadError);
		}
		
		private function onManifestLoaded(event:Event):void
		{
			event.target.addEventListener(Event.COMPLETE, onManifestLoaded);
			event.target.addEventListener(IOErrorEvent.IO_ERROR, onManifestLoadError);
			
			var manifest:XML = new XML(event.target.data);
			loadManifest(manifest);
			_assetManager.loadQueue(onLoadProgress);
		}
		
		public function loadAssetsQueue(onProgressCallback:Function):void
		{
			_assetManager.loadQueue(onProgressCallback);
		}
		
		private function onLoadProgress(progress:Number):void
		{
			//var progressPercent:int = progress * 100;
			//trace ("loading..." + progressPercent + "%");
			/*if (_loadingScreen)
			{
				_loadingScreen.updateLoadProgress(progress);
			}*/
			
			if (progress == 1 && MangoAssetManager.I.isLoadingDone)
			{
				Logger.log("assets ready!");
				_manifestLoadedCallback.call();
				
				System.pauseForGCIfCollectionImminent(0);
				System.gc();
				
				//detachLoadingScreen();
				//ProxySignals.getInstance().assetsreadySignal.dispatch(); // everything's up, notify others
				
			}
		}
		
		private function onManifestLoadError(event:Event):void
		{
			throw new Error("failed to load manifest!");
		}
		
		private function loadManifest(manifest:XML):void
		{
			for each (var node:XML in manifest.children())
			{
				switch (node.localName())
				{
					case "images": processImages(node); break;
					case "audio": processAudio(node); break;
					case "positions": processPositions(node); break;
					case "data": processGameData(node); break;
					case "fonts": processFonts(node); break;
				}
			}
			
			function processImages(imagesXML:XML):void
			{
				for each (var node:XML in imagesXML.children())
				{
					var path:String = Constants.assetPathPrefix + ASSET_LOCATION + "/themes/" + _themeLocation + "/" + _imageLocation + "/" + node.@path;
					_assetManager.enqueue(path);
					
					var isAtlas:Boolean = node.@isAtlas == "true";
					if (isAtlas)
					{
						path = path.replace(".png", ".xml"); // HACK: may not be safe
						_assetManager.enqueue(path);
					}
				}
			}
			
			function processAudio(audioXML:XML):void
			{
				for each (var node:XML in audioXML.children())
				{
					var path:String = Constants.assetPathPrefix + ASSET_LOCATION + "/" + _audioLocation + "/" + node.@path;
					_assetManager.enqueue(path);
				}
			}
			
			function processPositions(positionXML:XML):void
			{
				for each (var node:XML in positionXML.children())
				{
					loadPosition(node.@path);
				}
			}
			
			function processGameData(gameDataXML:XML):void
			{
				for each (var node:XML in gameDataXML.children())
				{
					//loadGameData(node.@path);
				}
			}
			
			function processFonts(fontsXml:XML):void
			{
				for each (var node:XML in fontsXml.children())
				{
					var path:String = Constants.assetPathPrefix + ASSET_LOCATION + "/" + _fontsLocation + "/" + node.@path;
					_assetManager.enqueue(path);
				}
			}
		}
		
		private function loadPosition(name:String):void
		{
			var path:String = Constants.assetPathPrefix + ASSET_LOCATION + "/themes/" + _themeLocation + "/" + _positionLocation + "/" + name;
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(new URLRequest(path));
			_xmlsToLoad++;
			urlLoader.addEventListener(Event.COMPLETE, function (event:Event):void
			{
				_xmlsLoaded++;
				event.target.removeEventListener(event.type, arguments.callee);
				var xml:XML = new XML(event.target.data);
				switch (xml.localName())
				{
					case "fontsize": Fonts.getInstance().setFontXML(xml); break;
					case "mainscreen": _mainElements = xml; break;
					case "gamescreen": _gameElements = xml; break;
				}
			});
		}
		
		private function loadGameData(name:String):void
		{
			var appDir:File = File.applicationDirectory;
			var path:String = Constants.assetPathPrefix + ASSET_LOCATION + "/data/" + name;
			var urlLoader:URLLoader = new URLLoader();
			var pathFile:File	= appDir.resolvePath(path);
			trace(pathFile.url);
			urlLoader.load(new URLRequest(pathFile.url));
			_xmlsToLoad++;
			urlLoader.addEventListener(Event.COMPLETE, function (event:Event):void
			{
				_xmlsLoaded++;
				event.target.removeEventListener(event.type, arguments.callee);
				var xml:XML = new XML(event.target.data);
				switch (xml.localName())
				{
					case "GameData": _gameData 	= xml; break;
					case "gamerules": _gameRules = xml; break;
				}
			});
		}
		
		public function showLoadingScreen():void
		{
			_loadingScreen = new LoadingScreen();
			Starling.current.stage.addChild(_loadingScreen);
		}
		
		public function detachLoadingScreen():void
		{
			if (!_loadingScreen)
				return;
			
			_loadingScreen.parent.removeChild(_loadingScreen);
			_loadingScreen.dispose();
			_loadingScreen = null;
		}
		
		public function getImage(name:String, scaleType:String = ScaleType.NONE):Image
		{
			var image:Image = new Image(getTexture(name));
			if (scaleType != ScaleType.NONE)
				ScaleUtils.applyScale(image, scaleType);
			
			return image;
		}
		
		public function getTexture(name:String):Texture	{ return _assetManager.getTexture(name); }
		public function getTextures(name:String):Vector.<Texture> { return _assetManager.getTextures(name); }
		public function getSound(name:String):Sound { return _assetManager.getSound(name); }
		
		public function get isLoadingDone():Boolean { return (_xmlsLoaded / _xmlsToLoad) == 1; }
		public function get mainElements():XML { return _mainElements; }
		public function get gameElements():XML { return _gameElements; }
		public function get gameData():XML {return _gameData}
		public function get gameRules():XML {return _gameRules}
	}
}

internal class InternalLocker{};