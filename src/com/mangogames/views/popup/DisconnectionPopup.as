package com.mangogames.views.popup
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.services.SFSInterface;
	
	import feathers.controls.Button;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	public class DisconnectionPopup extends Sprite
	{
		public function DisconnectionPopup()
		{
			// bg
			var bg:Image = new Image(MangoAssetManager.I.getTexture("msg_popup"));
			bg.width	= 360;
			bg.height	= 200;
			addChild(bg);
			
			// icon
			/*var disconnectIcon:Image = new Image(MangoAssetManager.I.getTexture("disconnect"));
			disconnectIcon.x = (width - disconnectIcon.width) / 2;
			disconnectIcon.y = (height - disconnectIcon.height) / 2;
			addChild(disconnectIcon);*/
			
			// title
			var label:TextField = BuyInPopUp.createLabel("INTERNET CONNECTION LOST", 100, 10);
			label.x = (width - label.width) / 2;
			label.format.size	= 12;
			addChild(label);
			
			// body message
			label = BuyInPopUp.createLabel("	Please check your internet connection \n      		and reload the game", 100, 80);
			label.x = (width - label.width) / 2;
			addChild(label);
			
			 // join me btn
			
			var amBack:Button	= new Button();
			amBack.x			= (bg.width - amBack.width)/2;
			amBack.y			= bg.height - amBack.height;
			addChild(amBack);
			amBack.addEventListener(Event.TRIGGERED, onAmBackHandler);
			
		}
		
		private function onAmBackHandler(event:Event):void
		{
			//SFSInterface.getInstance().joinMeBack(
		}
	}
}