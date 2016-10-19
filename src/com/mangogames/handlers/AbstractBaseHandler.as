package com.mangogames.handlers
{
	import com.mangogames.models.IGame;
	import com.mangogames.rummy.model.impl.PiggybackImpl;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.game.GameView;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	
	import logger.Logger;
	
	import utils.PiggyActionID;

	public class AbstractBaseHandler
	{
		public function AbstractBaseHandler()
		{
		}
		
		public function raju(params:Object):void
		{
			// nothing to do here
		}
		
		public function admmsg(params:Object):void
		{
			var playerId:int = params.params.getLong("playerid");
			var title:String = params.params.getUtfString("title");
			var message:String = params.params.getUtfString("message");
			
			Logger.log("admmsg: " + title + "- " + message);
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.admmsgSignal.dispatch(playerId , title , message);
		}
		
		public function processPiggyback(params:Object):void
		{
			if (!params.params)
				return;
			
			var piggyback:PiggybackImpl = params.params.getClass("PiggybackImpl");
			if (!piggyback)
				return;
			
			if (piggyback.actionId)
				processTargettedPiggyback(piggyback);
			if (piggyback.subActionId && piggyback.subActionId > -1)
				processTargettedPiggyback(piggyback);
			
			function processTargettedPiggyback(piggyback:PiggybackImpl):void
			{
				Logger.log("processing piggyback id: " + piggyback.actionId);
				switch(piggyback.actionId)
				{
					case PiggyActionID.AccountUpdated:
						ProxySignals.getInstance().updateuseraccountSignal.dispatch(piggyback.chips, piggyback.realMoney);
						break;
					
					case PiggyActionID.UpdateInventory:
						ProxySignals.getInstance().updateinventorySignal.dispatch();
						break;
					
					case PiggyActionID.BuyInAmount:
						var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
						if (gameView)
							gameView.buyinSignal.dispatch();
						break;
				}
			}
		}
		
		protected function fetchGameType(params:ISFSObject):IGame
		{
			var game:IGame = null;
			
			if (params.getClass("PointsGameImpl"))
				game = params.getClass("PointsGameImpl");
			else if (params.getClass("SyndicateGameImpl"))
				game = params.getClass("SyndicateGameImpl");
			else if (params.getClass("BestOfNGameImpl"))
				game = params.getClass("BestOfNGameImpl");
			
			return game;
		}
	}
}