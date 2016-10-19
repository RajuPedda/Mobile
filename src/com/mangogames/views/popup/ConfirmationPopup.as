package com.mangogames.views.popup
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.views.AbstractBaseView;
	
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	
	import utils.Fonts;
	import utils.ScaleUtils;
	
	public class ConfirmationPopup extends Sprite
	{
		public function ConfirmationPopup(headerMessage:String, message:String, okCallback:Function=null, cancelCallback:Function=null, autoCloseTime:int = -1, autoCloseCallback:Function = null)
		{
			super();
			
			var obj:Object			= AbstractBaseView.getStageSize();
			var STAGE_WIDTH:int		= obj.stageWidth;
			var STAGE_HEIGHT:int	= obj.stageHeight;
			
			var bgTexture:Texture	= MangoAssetManager.I.getTexture("msg_popup");
			var reqW:int			= STAGE_HEIGHT/8;
			var image:Image	= new Image(bgTexture);
			image.scale9Grid= new Rectangle( 40, 40, reqW, reqW );
			addChild( image );
			
			var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 16;
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, fontSize, Fonts.getInstance().colorWhite);
			var headerMsg:TextField = new TextField(width - 10, 1, headerMessage, tf);
			headerMsg.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			//headerMsg.format.bold	= true;
			headerMsg.x = (width - headerMsg.width) / 2;
			//headerMsg.format.size	*= ScaleUtils.scaleFactorNoBorder;
			headerMsg.y = 5;
			addChild(headerMsg);
			
			fontSize	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 18;
			
			tf	= new TextFormat(Fonts.getInstance().fontRegular, fontSize, Fonts.getInstance().colorWhite);
			var txtMessage:TextField = new TextField(width-10, 1, message, tf);
			txtMessage.autoSize = TextFieldAutoSize.VERTICAL;
			txtMessage.x = (width - txtMessage.width) / 2;
			txtMessage.y = image.height/2-20;
			//txtMessage.format.size	*= ScaleUtils.scaleFactorNoBorder;
			addChild(txtMessage);
			
			if (okCallback != null)
			{
				var btnOk:Button = new Button(MangoAssetManager.I.getTexture("ok_btn"), "");
				ScaleUtils.applyPercentageScale(btnOk, 9, 6);
				btnOk.textFormat.font = Fonts.getInstance().fontBold;
				btnOk.textFormat.color = Fonts.getInstance().colorWhite;
				btnOk.textFormat.size = Fonts.getInstance().smallFont;
				btnOk.x = (width - btnOk.width) / 2;
				btnOk.y = image.height-btnOk.height*1.6;
				addChild(btnOk);
				btnOk.addEventListener(Event.TRIGGERED, onOk);
			}
			
			if (cancelCallback != null)
			{
				var btnCancel:Button = new Button(MangoAssetManager.I.getTexture("cancel_btn"), "");
				ScaleUtils.applyPercentageScale(btnCancel, 9, 6);
				btnCancel.textFormat.font = Fonts.getInstance().fontBold;
				btnCancel.textFormat.color = Fonts.getInstance().colorWhite;
				btnCancel.textFormat.size = Fonts.getInstance().smallFont;
				btnOk.x = 20;
				btnCancel.x = width - btnCancel.width - 20;
				btnCancel.y = image.height-btnCancel.height*1.6;
				addChild(btnCancel);
				btnCancel.addEventListener(Event.TRIGGERED, onCancel);
			}
			
			// auto close timer
			if (autoCloseTime != -1)
			{
				var timer:Timer = new Timer(1000, autoCloseTime);
				timer.addEventListener(TimerEvent.TIMER, onTimerTick);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onAutoClose);
				timer.start();
			}
			
			// handlers
			function onTimerTick(event:TimerEvent):void
			{
				// TODO
			}
			
			function onOk(event:Event):void
			{
				okCallback();
				closePopup();
			}
			
			function onCancel(event:Event):void
			{
				cancelCallback();
				closePopup();
			}
			
			function onAutoClose(event:TimerEvent):void
			{
				if (autoCloseCallback != null)
					autoCloseCallback();
				else
					cancelCallback();
				
				closePopup();
			}
			
			var popup:ConfirmationPopup = this;
			function closePopup():void
			{
				if (timer)
				{
					timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
					timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onAutoClose);
					timer.stop();
				}
				
				if (PopUpManager.isPopUp(popup))
					PopUpManager.removePopUp(popup, true);
			}
		}
	}
}