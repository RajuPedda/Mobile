package com.mangogames.views.game.tableview
{
	import com.mangogames.views.game.GameView;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	import utils.Fonts;
	import utils.ScaleUtils;
	
	public class CountDownView extends Sprite
	{
		private var _ticks:int;
		private var _message:String;
		private var _color:int;
		private var _autoDispose:Boolean;
		private var _showTimer:Boolean;
		private var _timer:Timer;
		private var _txtMessage :TextField
		private var _gameView:GameView = null;
		private var _callBack:Function;
		public var last1SecCallBack:Function;
		private var _bg:Image;
		
		public function CountDownView(ticks:int, message:String, autoDispose:Boolean, showTimer:Boolean, gameView:GameView, callBack:Function= null, oneSecCallback:Function=null)
		{
			super();
			
			_callBack	= callBack;
			last1SecCallBack	= oneSecCallback;
			_ticks = ticks;
			_message = message;
			_autoDispose = autoDispose;
			_gameView = gameView;
			_showTimer = showTimer;
			
			
			_color = 0xFFFFFF;
			
			// add the message
			var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 16;
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, fontSize, _color, "center");
			_txtMessage = new TextField(1, 1, _message + _ticks.toString(), tf);
			_txtMessage.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			addChild(_txtMessage);
			
			// start the timer
			_timer = new Timer(1000);
			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, onTimerTick);
		}
		
		private function onTimerTick(event:TimerEvent):void
		{
			_ticks--;
			
			if (_ticks > 0)
			{
				if(_ticks == 1)
				{
					if(last1SecCallBack !=null)
						last1SecCallBack.call();
				}
					
				
				_txtMessage.text = _showTimer ? _message + _ticks.toString() : _message;
			}
			else if (_autoDispose)
			{
				if(_callBack != null)
					_callBack.call();
				dispose();
			}
			
			if(_message == "Game will starts in " && _ticks <= 10 && _ticks >= 3 && _gameView != null)
				_gameView.leaveTableDisableSignal.dispatch();
		}
		
		override public function dispose():void
		{
			if(_timer)
			{
				_timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
				_timer.stop();
				_timer = null;
			}
			
			if(_txtMessage)
			{
				_txtMessage.removeChildren(0, -1, true);
				_txtMessage = null;
			}
			super.dispose();
		}
	}
}