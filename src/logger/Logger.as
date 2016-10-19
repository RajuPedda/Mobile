package logger
{
	import com.mangogames.signals.ProxySignals;
	
	
	
	public class Logger
	{
		public static function log(text:String):void
		{
			text = "[A2K-LOG] " + text;
			ProxySignals.getInstance().loggerSignal.dispatch(text);
			//ExternalInterface.call("console.log", text);
		}
	}
}