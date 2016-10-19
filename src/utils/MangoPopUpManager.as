package utils
{		
	
	import com.mangogames.views.SettingsPanel;
	import com.mangogames.views.popup.BasePopup;
	
	import feathers.core.DefaultPopUpManager;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	public class MangoPopUpManager extends DefaultPopUpManager
	{
		public function MangoPopUpManager()
		{
			super();
		}
				
		override public function set root(value:DisplayObjectContainer):void
		{
			_root = value;
		}
		
		override public  function addPopUp(popUp:DisplayObject, isModal:Boolean=true, isCentered:Boolean=true, customOverlayFactory:Function=null):DisplayObject
		{
			var newPopup:DisplayObject = super.addPopUp(popUp, isModal, isCentered, customOverlayFactory);
			newPopup.pivotX = newPopup.width/2;
			newPopup.pivotY = newPopup.height/2;
			newPopup.x = Constants.TARGET_WIDTH/2;
			newPopup.y = Constants.TARGET_HEIGHT/2;
			newPopup.scaleX = 0.1;
			newPopup.scaleY = 0.1;
			
			var tween:Tween = new Tween(newPopup, 0.5, Transitions.EASE_IN_OUT);
			tween.scaleTo(1);
			Starling.juggler.add(tween);
			
			return newPopup;
		}
		
		override public function removePopUp(popUp:DisplayObject, dispose:Boolean=false):DisplayObject
		{
			var tween:Tween = new Tween(popUp, 0.2, Transitions.EASE_IN_OUT);
			tween.scaleTo(0.1);
			tween.onComplete = tween_complete;
			tween.onCompleteArgs = [popUp, dispose];
			Starling.juggler.add(tween);
			
			return 	popUp;
		}
		
		public function closeTopMostPopup():void
		{
			var topMostPopUp:DisplayObject = _popUps[0];
			if (topMostPopUp is BasePopup && BasePopup(topMostPopUp).canAutoClose)
				BasePopup(topMostPopUp).closePopup();
			else if (topMostPopUp is SettingsPanel)
				removePopUp(topMostPopUp, true);
		}
		
		public function getOverlayForPopup(popup:DisplayObject):DisplayObject
		{
			var overlay:DisplayObject = DisplayObject(this._popUpToOverlay[popup]);
			return overlay;
		}
		
		private function tween_complete(popUp:DisplayObject, dispose:Boolean=false):void
		{
			popUp.scaleX = 1;
			popUp.scaleY = 1;
			
			if(this.isPopUp(popUp))
				super.removePopUp(popUp,dispose);
		}
		
		public function get hasPopUps():Boolean { return _popUps.length > 0; }
		public function get topMostPopup():BasePopup { return _popUps.length > 0 ? _popUps[0] as BasePopup : null; }
	}
}