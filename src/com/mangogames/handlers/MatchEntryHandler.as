package com.mangogames.handlers
{
	import com.mangogames.rummy.model.impl.DealImpl;
	import com.mangogames.rummy.model.impl.DealerImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.MatchImpl;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.views.game.GameView;
	
	public class MatchEntryHandler extends AbstractBaseHandler
	{
		public function MatchEntryHandler()
		{
			super();
		}
		
		public function matchstarting(params:Object):void
		{
			var matchImpl:MatchImpl = params.params.getClass("MatchImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.matchstartingSignal.dispatch(matchImpl);
		}
		
		public function shuffleanddeal(params:Object):void
		{
			var deal:DealImpl = params.params.getClass("DealImpl");
			var handCards:HandCardsImpl = params.params.getClass("HandCardsImpl");
			var roundCount:int = params.params.getInt("roundcount");
			var displayId:String = params.params.getUtfString("displayid");
			
			trace("HAND CARDS ----- >>>>>>>> "+ handCards.groupcards[0].card.length);
			if(handCards.groupcards[0].card.length > 13)
			{
				trace("HAND CARDS -- >>> WRONG WRONG WRONG ----->>>>>>");
			}
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.shuffleanddealSignal.dispatch(deal, handCards, roundCount, displayId);
		}
		
		public function matchstarted(params:Object):void
		{
			var seatId:int = params.params.getLong("seatId");
			var timeOut:int = params.params.getInt("timeout");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.matchstartedSignal.dispatch(seatId, timeOut);
		}
		
		public function countdown(params:Object):void
		{
			var tick:int = params.params.getInt("Tick");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.startcountdownSignal.dispatch(tick);
		}
		
		public function stopcountdown(params:Object):void
		{
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.stopcountdownSignal.dispatch();
		}
		
		public function dealover(params:Object):void
		{
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				SFSInterface.getInstance().closeRoom(gameView.room.id, false);
		}
		
		public function getsetgo(params:Object):void
		{
			var deal:DealImpl = params.params.getClass("DealImpl");
			
			// TODO:
			trace ("todo: getsetgo!");
		}
		
		public function spectatordeal(params:Object):void
		{
			var deal:DealImpl 			= params.params.getClass("DealImpl");
			var displayId:String 		= params.params.getUtfString("displayid");
			var roundCount:int 			= params.params.getInt("roundcount");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.spectatorDealSignal.dispatch(deal,displayId, roundCount);
		}
	}
}