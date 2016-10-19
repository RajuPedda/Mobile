package com.mangogames.views.game
{
	import com.mangogames.managers.ConfigManager;
	import com.mangogames.views.game.tableview.DealerView;
	import com.mangogames.views.game.tableview.TableView;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.core.PopUpManager;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	
	import utils.Fonts;
	

	public class DealerCallout extends Sprite
	{
		private var _callOut:Callout;
		private var _callOutLabel:TextField;
		private var _dealer:DealerView;
		
		private var _timer:Timer = null;
		private var _tableView:TableView;
		
		private var _messageQueue:Array = null;
		
		public function DealerCallout(dealer:DealerView)
		{
			_dealer = dealer;
			_messageQueue = new Array();
			
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, Fonts.getInstance().smallFont, Color.WHITE);
			_callOutLabel = new TextField(1, 1, "", tf);
			_callOutLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		}
				
		/**
		 *  - Show callout
		 *  - If there is one currently showing, queue the message
		 *  - On timeout get next message and show.
		 *  - Exit when there is nothing in the queue		 *  
		 */
		public function animateCallout(message:String, durationInSecs:int = 0, forceTimeout:Boolean = true):void
		{
			// push the message in queue
			pushMessageInQueue(message, durationInSecs);
			
			if(_timer == null) // check if the timer is running
			{
				showCallout(message, durationInSecs);
			}
			else if(forceTimeout) // force timeout for the existing callout
			{
				onTimeout(null);
			}
		}
		
		private function pushMessageInQueue(message:String, duration:Number):void
		{
			var qMessage:QueueMessage = new QueueMessage(message, duration);
			_messageQueue.push(qMessage);
		}
		
		private function startTimer(durationInSecs:int):void
		{
			_timer = new Timer(durationInSecs * 1000)
			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, onTimeout);
		}
		
		private function onTimeout(event:TimerEvent):void
		{
			_timer.stop();			
			_timer = null;

			var currentMessage:QueueMessage = getFirstMessageFromQueue();
			
			if(currentMessage != null)
			{
				closeCallout();
				updateQueue();
			}
			
			var nextMessage:QueueMessage = getFirstMessageFromQueue();
			if(nextMessage != null && nextMessage.Message.length > 0)
			{
				showCallout(nextMessage.Message, nextMessage.Duration);
			}
		}
		
		private function getFirstMessageFromQueue():QueueMessage
		{
			var queueMessage:QueueMessage = null;
			
			if(_messageQueue.length > 0)
			{
				queueMessage = _messageQueue[0];
			}
			
			return queueMessage;
		}
		
		private function updateQueue():void
		{
			_messageQueue[0] = null;
			
			// this removes the last element from an array
			_messageQueue.splice(0, 1);
		}
		
		private function showCallout(message:String, durationInSecs:Number):void
		{
			startTimer(durationInSecs);
			
			//SettingsManager.I.currentTheme.setInitializerForClass(Label, labelInitalizer);
			
			_callOutLabel.text = message;
			PopUpManager.root = this.parent;
			_callOut = Callout.show(_callOutLabel, _dealer, Callout.DIRECTION_UP, false);
			_callOut.backgroundSkin.alpha = 0.7;
			_callOut.y = _dealer.y;
			_callOut.disposeContent = false;
			_callOut.disposeOnSelfClose = false;
		}
		
		private function closeCallout():void
		{
			if(_callOut != null)
			{
				_callOut.close();
				_callOut = null;				
			}
		}
		
		public function cleanUp():void
		{
			if(_callOut != null)
			{
				_callOut.close(true);
				_callOut.disposeContent = true;
				_callOut = null;
			}
			
			_messageQueue.splice(0, _messageQueue.length);

			this.removeChild(_callOutLabel, true);
		}
	}
}

internal class QueueMessage
{
	public var Message:String;
	public var Duration:Number;
	
	public function QueueMessage(message:String, duration:Number)
	{
		Message = message;
		Duration = duration;
	}
}
