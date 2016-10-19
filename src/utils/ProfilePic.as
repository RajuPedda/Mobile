package utils
{
	import com.mangogames.views.common.Hud;
	
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	import feathers.controls.ImageLoader;
	
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class ProfilePic extends Sprite
	{
		private var _picWidth:int = 128;
		private var _picHeight:int = 128;
		
		private var _imgPic:ImageLoader;
		private var _mcBusyIndicator:MovieClip;
		private var _iconUrl:String;
		
		public function ProfilePic(iconUrl:String)
		{
			super();
			
			_mcBusyIndicator = Hud.getBusyIndicator();
			addChild(_mcBusyIndicator);
			_iconUrl	= iconUrl;
			fetch();
		}
		
		override public function dispose():void
		{
			if (_mcBusyIndicator) _mcBusyIndicator.removeFromParent(true);
			if (_imgPic) _imgPic.removeFromParent(true);
			
			super.dispose();
		}
		
		private function fetch():void
		{
			Security.loadPolicyFile("crossdomain.xml");
			var loaderContextObj:LoaderContext = new LoaderContext();
			loaderContextObj.checkPolicyFile = true;
			loaderContextObj.applicationDomain = ApplicationDomain.currentDomain;
			
		/*	var imageLoader:Loader = new Loader();
			imageLoader.load(new URLRequest(_iconUrl),loaderContextObj);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onProfilePicLoaded);
			imageLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);*/
			
			
			_imgPic = new ImageLoader();
			_imgPic.source = _iconUrl ;
			_imgPic.addEventListener( Event.COMPLETE, onProfilePicLoaded );
			_imgPic.addEventListener(Event.IO_ERROR, onIOError);
			_imgPic.addEventListener(Event.SECURITY_ERROR, onSecurityError);
			this.addChild( _imgPic );
		}
		
		private function onIOError(ev:Event):void
		{
			//do nothing
			trace("IOError");
		}
		
		private function onSecurityError(ev:Event):void
		{
			trace("Error Data: ",ev.toString());
		}
		
		private function onProfilePicLoaded(event:starling.events.Event):void
		{
			// remove busy indicator
			_mcBusyIndicator.removeFromParent(true);
			_imgPic.width = _picWidth;
			_imgPic.height = _picHeight;
			
		}
		
		override public function set width(value:Number):void
		{
			if (_mcBusyIndicator)
				_mcBusyIndicator.width = value;
			
			_picWidth = value;
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			if (_mcBusyIndicator)
				_mcBusyIndicator.height = value;
			
			_picHeight = value;
			super.height = value;
		}
	}
}