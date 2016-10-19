package com.mangogames.controls
{
	import com.creativebottle.starlingmvc.views.ViewManager;
	import com.mangogames.views.LoadingScreen;
	
	import starling.display.Sprite;
	
	public class NavigationController
	{			
		public function NavigationController()
		{
		}
		
		[Inject]
		public var viewManager:ViewManager;
		
		[PostConstruct]
		public function postConstruct():void
		{
			// load the default view
			viewManager.setView(LoadingScreen, true);
		}
		
		[EventHandler(event="NavigationEvent.CHANGE_VIEW", properties="data")]
		public function changeView(data:Class):void
		{
			viewManager.setView(data);
		}
		
		[EventHandler(event="NavigationEvent.CHANGE_ROOM", properties="data")]
		public function changeRoom(data:Object):void
		{
			var roomID:String = data.roomID;
			var nextView:Class = data.nextView;
			viewManager.setView(nextView, roomID);
		}
		
		[EventHandler(event="NavigationEvent.ADD_VIEW", properties="data, stopImmediatePropagation")]
		public function addView(data:Sprite, stopEventPropagation:Function):void
		{
			stopEventPropagation();
			viewManager.addView(data);
		}
		
		[PreDestroy]
		public function preDestroy():void
		{
			// tear down code here
			trace("fsdafdsfsd");
		}
	}
}