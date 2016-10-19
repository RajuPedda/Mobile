package com.mangogames.views.popup
{
	import com.mangogames.managers.MangoAssetManager;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import feathers.core.PopUpManager;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	
	import utils.Fonts;
	
	public class ReshufflePopup extends Sprite
	{
		public function ReshufflePopup()
		{
			super();
			
			addChild(new Image(MangoAssetManager.I.getTexture("msg_popup")));  // width = 300, height = 200
			
			var message:String = "Reshuffling, please wait...";
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontBold, 12, Color.WHITE);
			var txtMessage:TextField = new TextField(1, 1, message, tf);
			txtMessage.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			txtMessage.format.bold	= true;
			txtMessage.x = (width - txtMessage.width) / 2;
			txtMessage.y = 70;
			addChild(txtMessage);
			
			// auto close timer
			var timer:Timer = new Timer(1000, 1); // resuffle
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.start();
			
			var popup:ReshufflePopup = this;
			function onTimerComplete(event:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				timer.stop();
				
				if (PopUpManager.isPopUp(popup))
					PopUpManager.removePopUp(popup, true);
			}
		}
	}
}