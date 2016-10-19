package com.mangogames.views.popup
{
	import com.mangogames.managers.MangoAssetManager;
	
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import feathers.controls.TextInput;
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	
	import utils.Fonts;
	import utils.ScaleUtils;
	
	public class BuyInPopUp extends Sprite
	{
		private const AUTO_CLOSE_TIME:Number = 8;
		private var _timeLeft:int;
		
		public function BuyInPopUp(minBuyIn:int, userBalance:int, callback:Function, isAutoClose:Boolean = true)
		{
			super();
			
			var txiAmount:TextInput;
			
			var background:Image = new Image(MangoAssetManager.I.getTexture("buyIn"));
			addChild(background); // width = 300, height = 200
			
			var xOffset:int = 30;
			var yOffset:int = 55;
			var columnDiffence:int = 120;
			var rowDiffernce:int = 30;
			
			var lblBet:TextField = createLabel("Bet", xOffset, yOffset);
			addChild(lblBet);
				
			xOffset += columnDiffence;

			var betAmount:String = ": " + (Number(minBuyIn / 1000) / 8).toFixed(2).toString();
			var lblBetAmount:TextField = createLabel(betAmount, xOffset, yOffset);
			lblBetAmount.format.color = Color.YELLOW;
			addChild(lblBetAmount);
			
			xOffset -= columnDiffence;
			yOffset += rowDiffernce; 
			
			var lblMinBuyIn:TextField = createLabel("Min BuyIn", xOffset, yOffset);
			addChild(lblMinBuyIn);
			
			xOffset += columnDiffence;
			
			var minBuyInAmount:String = ": " + (Number(minBuyIn / 100)).toFixed(2).toString();
			var lblMinBuyInAmount:TextField = createLabel(minBuyInAmount,xOffset, yOffset);
			lblMinBuyInAmount.format.color = Color.YELLOW;
			addChild(lblMinBuyInAmount);
			
			xOffset -= columnDiffence;
			yOffset += rowDiffernce; 
			
			var lblMaxBuyIn:TextField = createLabel("Max BuyIn", xOffset, yOffset);
			addChild(lblMaxBuyIn);
			
			xOffset += columnDiffence;
			
			var maxBuyInAmount:String = ": " + (Number(minBuyIn / 100) * 10).toFixed(2).toString();
			var lblMaxBuyInAmount:TextField = createLabel(maxBuyInAmount,xOffset, yOffset);
			lblMaxBuyInAmount.format.color = Color.YELLOW;
			addChild(lblMaxBuyInAmount);
			
			xOffset -= columnDiffence;
			yOffset += rowDiffernce; 

			var lblBalance:TextField = createLabel("Balance", xOffset, yOffset);
			addChild(lblBalance);
			
			xOffset += columnDiffence;
			
			var balanceAmount:String = ": " + (Number(userBalance / 100)).toFixed(2).toString();
			var lblBalanceAmount:TextField = createLabel(balanceAmount,xOffset, yOffset);
			lblBalanceAmount.format.color = Color.YELLOW;
			addChild(lblBalanceAmount);
			
			xOffset -= columnDiffence;
			yOffset += rowDiffernce; 
						
			var label:TextField = createLabel("Enter Buy in ", xOffset, yOffset);
			addChild(label);
			
			yOffset += rowDiffernce; 
			
			var autoBuyInText:TextField = createLabel("Exiting room in " + AUTO_CLOSE_TIME + " seconds.", 100, yOffset);
			autoBuyInText.x = (width - autoBuyInText.width) / 2;
			addChild(autoBuyInText);
			
			var btnOk:Button = new Button(MangoAssetManager.I.getTexture("ok_btn"), "");
			ScaleUtils.applyPercentageScale(btnOk, 10, 6);
			btnOk.textFormat.font = Fonts.getInstance().fontBold;
			btnOk.textFormat.size = Fonts.getInstance().mediumFont;
			btnOk.textFormat.color = Fonts.getInstance().colorWhite;
			addChild(btnOk);
			btnOk.x = (width - btnOk.width) / 2;
			btnOk.y = 245;
			btnOk.addEventListener(Event.TRIGGERED, onBuyIn);
			
			var popupZoomOutTimer:Timer = new Timer(300, 1);
			popupZoomOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onZoomOutCompleted);
			popupZoomOutTimer.start();
			
			var closeTimer:Timer;
			
			function onZoomOutCompleted(event:TimerEvent):void
			{
				popupZoomOutTimer.stop();
				popupZoomOutTimer.removeEventListener(TimerEvent.TIMER, onZoomOutCompleted);
				
				var balance:int = minBuyIn * 3 <= userBalance ? minBuyIn * 3 : userBalance; 

				//SettingsManager.I.currentTheme.setInitializerForClass(TextInput, textInputInitializer);
				txiAmount = new TextInput();
				addChild(txiAmount);
				txiAmount.x = 165;
				txiAmount.y = yOffset - rowDiffernce -5 ;
				txiAmount.text = (Number(balance / 100)).toFixed(2).toString(); // default amount
				txiAmount.isEnabled = true;
				txiAmount.isEditable	= true;
				txiAmount.selectRange(0);
				//txiAmount.setFocus();
				txiAmount.textEditorProperties.color = Fonts.getInstance().colorGold;
				txiAmount.textEditorProperties.fontFamily = Fonts.getInstance().fontRegular;
				txiAmount.textEditorProperties.fontSize = Fonts.getInstance().smallFont;
				//txiAmount.backgroundSkin	= 
				
				txiAmount.addEventListener(KeyboardEvent.KEY_DOWN, onTxiAmountEnter);
				if (isAutoClose)
				{
					closeTimer = new Timer(1000, AUTO_CLOSE_TIME);
					closeTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
					closeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
					closeTimer.start();
				}
			}
			
			function onTxiAmountEnter(event:KeyboardEvent):void
			{
				if(txiAmount.text.length >=1)
				{
					if(event.keyCode == Keyboard.ENTER)
					{
						onBuyIn();
					}
				}
			}
			
			function onTimerTick(event:TimerEvent):void
			{
				_timeLeft = closeTimer.repeatCount - closeTimer.currentCount;
				if(_timeLeft <=1)
				{
					btnOk.visible	= false;
					//buyIn(0);
				}
				autoBuyInText.text = "Exiting room in " + (_timeLeft - 1) + " seconds.";
			}
			
			function onTimerComplete(event:TimerEvent):void
			{
				buyIn(-2); // HACK: hardcoding
			}
			
			function onBuyIn(event:Event=null):void
			{
				var amount:Number = Number(txiAmount.text);
				buyIn(amount * 100);
			}
			
			var popup:Sprite = this;
			function buyIn(amount:int):void
			{
				if (isAutoClose)
				{
					closeTimer.stop();
					closeTimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
					closeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				}
				
				btnOk.removeEventListener(Event.TRIGGERED, onBuyIn);
				callback(amount);
				
				if (PopUpManager.isPopUp(popup))
					PopUpManager.removePopUp(popup, true);
			}
		}
		
		public static function createLabel(text:String, x:int, y:int):TextField
		{
			var textFormat:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, Fonts.getInstance().smallFont, Color.WHITE, "left");
			
			var label:TextField = new TextField(1, 1, text, textFormat);
			label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			label.alignPivot("left", "center");
			label.x = x;
			label.y = y;
			return label;
		}
		
		
		override public function dispose():void
		{
			removeChildren(0, -1, true);
			super.dispose();
		}
	}
}