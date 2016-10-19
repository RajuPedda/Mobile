package game
{
	import com.creativebottle.starlingmvc.StarlingMVC;
	import com.creativebottle.starlingmvc.config.StarlingMVCConfig;
	import com.creativebottle.starlingmvc.views.ViewManager;
	import com.mangogames.models.GameModelProvider;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.lobby.LobbyScreenView;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.motion.Slide;
	
	import logger.Logger;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import starling.events.Event;

	/**
	 * 
	 * @author Raju Pedda.M
	 * 
	 */	
	public class Main extends LayoutGroup
	{
		public function Main()
		{	
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			ProxySignals.getInstance().onLoadingDoneSignal.add(onLoadingDone);
			ProxySignals.getInstance().loginSuccessfulSignal.add(onSFSloginSuccess);
			SFSInterface.getInstance().mainStage = this;
		}
		
		private var _starlingMVC:StarlingMVC;
		private var _stackScreenNavigator:StackScreenNavigator;
		
		protected var _lobbyScreenSignal:Signal = new Signal();
		
		public function get lobbyScreenSignal():ISignal
		{
			return this._lobbyScreenSignal;
		}
		
		private function onLoadingDone():void
		{
			
		}
		
		private function onAddedToStage(event:Event):void
		{
			Logger.log("added to stage!");
			initStarlingMvc();
		}
		
		
		private function onSFSloginSuccess():void
		{
			//dispatchEventWith("lobbyScreenSignal", true);
			//_stackScreenNavigator.pushScreen("lobbyScreen");
		}
		
		
		private function initStarlingMvc():void
		{
			Logger.log("Raju Raju");
			var config:StarlingMVCConfig = new StarlingMVCConfig();
			config.eventPackages = ["com.mangogames.events"];
			config.viewPackages = [
				"com.mangogames.views",
				"com.mangogames.views.login",
				"com.mangogames.views.lobby",
				"com.mangogames.views.game",
				"com.mangogames.views.game.tableview",
			];
			
			// GameObjectProvider defines the initial beans that are used
			var beans:Array = [new GameModelProvider, new ViewManager(this)];
			_starlingMVC = new StarlingMVC(this, config, beans);
		}
	}
}