package com.mangogames.views.game.tableview
{
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class CountTimer extends Timer
	{
		private var targetText:TextField;
		private var direction:String;
		private var minutes:int;
		private var seconds:int;
		private var totalSeconds:int;
		private var timeTotal:int;
		private var timeLoaded:int = 0;
		private var test:Boolean = false;
		
		
		public function CountTimer(min:int,sec:int,dir:String,targetTextField:TextField=null)
		{
			minutes = int(min * 60);
			seconds = int(sec);
			timeTotal = minutes + seconds;
			super(1000,timeTotal);
			if (dir == "down")
			{
				totalSeconds = minutes + seconds;
			}
			else
			{
				totalSeconds = 0;
			}
			if (targetTextField != null)
			{
				targetText = targetTextField;
			}
			direction = dir;
		}

		override public function start():void
		{
			super.start();
			addEventListener(TimerEvent.TIMER, timerHandler);
		}
		private function timerHandler(e:TimerEvent):void
		{
			//Update our time Loaded variable
            timeLoaded +=  1;

			if (direction == "up")
			{
				//We set totalSeconds in our constructor function
				//Here it is = 0. We add to it.
				totalSeconds++;
			}
			else
			{
				//We set totalSeconds in our constructor function
				//Here it is equal to the total amount of seconds
				//We decrease the totalSeconds here
                totalSeconds--;
			}

            //How may seconds there are left.
			seconds = totalSeconds % 60;
			//How many minutes are left
			minutes = Math.floor(totalSeconds / 60);
			//The minutes and seconds to display in the TextField.
            var minutesDisplay:String = (minutes< 10) ? "0" + minutes.toString() : minutes.toString();
			var secondsDisplay:String = (seconds<10) ? "0"+seconds.toString(): seconds.toString();
			if (targetText != null)
			{
				targetText.text = minutesDisplay + ":" + secondsDisplay;
			}
			if(test==true){
				trace(minutesDisplay + ":" + secondsDisplay);
			}
		}
		public function getTimeTotal():int
		{
			return timeTotal;
		}
		public function getTimeLoaded():int
		{
			return timeLoaded;
		}
		public function getProg():int
		{
			return Math.floor(timeLoaded/timeTotal*100);

		}
	}

}