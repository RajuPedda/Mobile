package com.mangogames.views.popup
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.services.SFSInterface;
	import com.smartfoxserver.v2.entities.SFSRoom;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	import utils.Fonts;
	
	public class RejoinPopup extends Sprite
	{
		private var timer:Timer;
		private var _cancelCallBack:Function;
		private var _playerId:int;
		
		public function RejoinPopup(points:int, forceExit:int, room:SFSRoom, cancelCallBack:Function, playerId:int)
		{
			super();
			_cancelCallBack	= cancelCallBack;
			_playerId		= playerId;
			
			var bg:Image	= new Image(MangoAssetManager.I.getTexture("msg_popup"));
			//bg.width		= 360;
			addChild(bg);
			//addChild(new Image(MangoAssetManager.I.getTexture("popup_400x200")));  // width = 300, height = 200
			
			var headerMsg:String = forceExit == 1 ? "Lost Game" : "Rejoin";
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontBold, Fonts.getInstance().smallFont, Fonts.getInstance().colorWhite)
			var headertxtMessage:TextField 		= new TextField(1, 1, headerMsg,  tf);
			headertxtMessage.autoSize 			= TextFieldAutoSize.BOTH_DIRECTIONS;
			headertxtMessage.format.bold		= true;
			headertxtMessage.x 					= (width - headertxtMessage.width) / 2;
			headertxtMessage.y 					= 5;
			addChild(headertxtMessage);
			
			var message:String = forceExit == 1 ? "You have lost the game,\n you will be moving to lobby!" : "Rejoin with points: " + points.toString();
			tf	= new TextFormat(Fonts.getInstance().fontBold, Fonts.getInstance().smallFont, Fonts.getInstance().colorWhite)
			var txtMessage:TextField = new TextField(1, 1, message, tf);
			txtMessage.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			txtMessage.format.bold	= true;
			txtMessage.x = (width - txtMessage.width) / 2;
			txtMessage.y = 80;
			addChild(txtMessage);
			
			var btnOk:Button = new Button(MangoAssetManager.I.getTexture("ok_btn"));
			btnOk.textFormat.font = Fonts.getInstance().fontBold;
			btnOk.textFormat.color = Fonts.getInstance().colorWhite;
			btnOk.textFormat.size = Fonts.getInstance().smallFont;
			btnOk.x = 20;
			btnOk.y = 150;
			addChild(btnOk);
			btnOk.addEventListener(Event.TRIGGERED, onOk);
			
			var btnCancel:Button = new Button(MangoAssetManager.I.getTexture("cancel_btn"));
			btnCancel.textFormat.font = Fonts.getInstance().fontBold;
			btnCancel.textFormat.color = Fonts.getInstance().colorWhite;
			btnCancel.textFormat.size = Fonts.getInstance().smallFont;
			btnCancel.x = width - btnCancel.width - 20;
			btnCancel.y = 150;
			addChild(btnCancel);
			btnCancel.addEventListener(Event.TRIGGERED, onCancel);
			
			// auto close timer
			timer = new Timer(1000, 11);
			timer.addEventListener(TimerEvent.TIMER, onTimerTick);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCancel);
			timer.start();
			
			// handlers
			function onTimerTick(event:TimerEvent):void
			{
				// TODO
				var timeLeft:int = timer.repeatCount - timer.currentCount;
				if(timeLeft <=1)
				{
					btnOk.enabled	= false;
				}
			}
			
			function onOk(event:Event):void
			{
				if (forceExit == 1)
					SFSInterface.getInstance().closeRoom(room.id, true);
				else
				{
						SFSInterface.getInstance().rejoin(points, room, false);
				}
				
				closePopup();
			}
			
			function onCancel(event:*):void
			{
				_cancelCallBack.call(true, _playerId);
				SFSInterface.getInstance().sendRoomInfo(room, true);
				SFSInterface.getInstance().rejoin(points, room, true);
				SFSInterface.getInstance().closeRoom(room.id, true);
				closePopup();
			}
			
			var popup:RejoinPopup = this;
			function closePopup():void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onCancel);
				timer.stop();
				
				if (PopUpManager.isPopUp(popup))
					PopUpManager.removePopUp(popup, true);
			}
		}
	}
}