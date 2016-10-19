package com.mangogames.handlers
{
	import com.mangogames.models.IGame;
	import com.mangogames.rummy.model.impl.BestOfNGameImpl;
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.DealImpl;
	import com.mangogames.rummy.model.impl.DealPlayerImpl;
	import com.mangogames.rummy.model.impl.GroupCardsImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.MatchImpl;
	import com.mangogames.rummy.model.impl.MatchPlayerImpl;
	import com.mangogames.rummy.model.impl.MatchSettlementImpl;
	import com.mangogames.rummy.model.impl.OpenDeckImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.PointsGameImpl;
	import com.mangogames.rummy.model.impl.ScoreImpl;
	import com.mangogames.rummy.model.impl.SeatImpl;
	import com.mangogames.rummy.model.impl.SyndicateGameImpl;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.game.GameView;
	
	public class GameEntryHandler extends AbstractBaseHandler
	{
		private var _gameImplTemp:PointsGameImpl;
		private var _matchPlayerTemp:MatchPlayerImpl;
		private var _scoreTemp:ScoreImpl;
		private var _dealPlayerTemp:DealPlayerImpl;
		private var _syndicateGameTemp:SyndicateGameImpl
		private var _bestOfNGameTemp:BestOfNGameImpl;
		
		public function GameEntryHandler()
		{
			super();
		}
		
		public function RoomCreationFailed(params:Object):void
		{
			//ErrorHandler.log(GameEntryHandler,"Room Creation failed");
		}
		
		// validation reply 
		public function validatedjoin(params:Object):void
		{
			// 1 for success
			var validated:int = params.params.getInt("validatedjoin");
		}
		
		public function seatallotted(params:Object):void
		{
			var game:IGame 			= fetchGameType(params.params);
			var seatId:int 			= params.params.getInt("seatid");
			var minBuyIn:int 		= params.params.getInt("minbuyin");
			var player:PlayerImpl 	= params.params.getClass("PlayerImpl");
			
			var gameView:GameView 	= SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.seatallottedSignal.dispatch(game, seatId, minBuyIn, player);
		}
		
		public function gamemiddlejoin(params:Object):void
		{
			var game:IGame 				= fetchGameType(params.params);
			var match:MatchImpl 		= params.params.getClass("MatchImpl");
			var seatId:int 				= params.params.getInt("seatid");
			var deal:DealImpl 			= params.params.getClass("DealImpl");
			var handCards:HandCardsImpl = params.params.getClass("HandCardsImpl"); // need to check coming from server
			var minBuyIn:int 			= params.params.getInt("minbuyin");
			var turnTimeRemaining:int 	= params.params.getInt("turnticker");
			var turnTimerSeatId:int 	= params.params.getInt("turntimerseatid");
			var displayId:String 		= params.params.getUtfString("displayid");
			var seatImpl:SeatImpl 		= params.params.getClass("SeatImpl");
			var player:PlayerImpl		= params.params.getClass("PlayerImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
			{
				var data:Object			= {};
				data.game				= game;
				data.seatId				= seatId;
				data.match				= match;
				data.deal				= deal;
				data.handCards			= null; //handCards;
				data.minBuyIn			= minBuyIn;
				data.turnTimeRemaining	= turnTimeRemaining;
				data.turnTimerSeatId	= turnTimerSeatId;
				data.displayId			= displayId;
				data.seatImpl			= seatImpl;
				data.player				= player;
				gameView.gamemiddlejoinSignal.dispatch(data);// (game, seatId, match, deal, handCards, minBuyIn, turnTimeRemaining, turnTimerSeatId, displayId);
			}
		}
		
		// To-Do - need to make model class for this 
		public function mytableseatnotification(params:Object):void
		{
			var game:IGame 				= fetchGameType(params.params);
			var match:MatchImpl 		= params.params.getClass("MatchImpl");
			var seatId:int 				= params.params.getInt("seatid");
			var deal:DealImpl 			= params.params.getClass("DealImpl");
			var handCards:HandCardsImpl = params.params.getClass("HandCardsImpl"); // need to check coming from server
			var minBuyIn:int 			= params.params.getInt("minbuyin");
			var turnTimeRemaining:int 	= params.params.getInt("turnticker");
			var turnTimerSeatId:int 	= params.params.getInt("turntimerseatid");
			var displayId:String 		= params.params.getUtfString("displayid");
			var seatImpl:SeatImpl 		= params.params.getClass("SeatImpl");
			var player:PlayerImpl		= params.params.getClass("PlayerImpl");
			var showTicker:int			= params.params.getInt("showticker");
			var showInitTicker:int		= params.params.getInt("showinitticker");
			var scoreCardTicker:int		= params.params.getInt("scorecardticker");
			var isShowSubmitted:Boolean = params.params.getBool("showsubmit");
			var isShowInitiator:Boolean = params.params.getBool("showinitiator");
			var openDeck:OpenDeckImpl	= params.params.getClass("OpenDeckImpl");
			var currentOpenCardTurn:int	= params.params.getInt("currentturn");
			var roundCount:int 			= params.params.getInt("roundcount");
			
			
			if(handCards)
			{
				var cards:Array				= GroupCardsImpl(handCards.groupcards[0]).card;
				var pickedCard:CardImpl;
				// if the player picked the card and closes his/her browser and joins from the my table
				// then server will give 14 cards and the last card will be the last picked card
				if(cards.length == 14)
				{
					pickedCard	= cards[cards.length-1];
					handCards.groupcards[0].card.splice(13, 1)
				}
			}
			
			var joker:CardImpl			= null;
			var discardedCard:CardImpl	= null;
			
			if(scoreCardTicker >0)
				joker					= params.params.getClass("CardImpl");
			else
				discardedCard			= params.params.getClass("CardImpl");
			
			var matchSettlement:MatchSettlementImpl = params.params.getClass("MatchSettlementImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
			{
				var data:Object			= {};
				data.game				= game;
				data.seatId				= seatId;
				data.match				= match;
				data.deal				= deal;
				data.handCards			= handCards;
				data.minBuyIn			= minBuyIn;
				data.turnTimeRemaining	= turnTimeRemaining;
				data.turnTimerSeatId	= turnTimerSeatId;
				data.displayId			= displayId;
				data.seatImpl			= seatImpl;
				data.player				= player;
				data.showTicker			= showTicker;
				data.showInitTicker		= showInitTicker;
				data.matchSettlement	= matchSettlement;
				data.scoreCardTicker	= scoreCardTicker;
				data.joker				= joker;
				data.discardedCard		= discardedCard;
				data.isShowSubmitted	= isShowSubmitted;
				data.isShowInitiator	= isShowInitiator;
				data.pickedCard			= pickedCard;
				data.openDeck			= openDeck;
				data.currentOpenCardTurn= currentOpenCardTurn;
				data.roundCount			= roundCount;
				
				gameView.myTableGameJoinSignal.dispatch(data);// (game, seatId, match, deal, handCards, minBuyIn, turnTimeRemaining, turnTimerSeatId, displayId);
			}
		}
		
		public function newplayerjoined(params:Object ):void
		{
			var seatImpl:SeatImpl 		= params.params.getClass("SeatImpl");
			var playerImpl:PlayerImpl 	= params.params.getClass("PlayerImpl");
			var amount:int				= params.params.getLong("amount");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.newplayerjoinedSignal.dispatch(seatImpl, playerImpl, amount);
		}
		
		public function userexitroom(params:Object):void
		{
			ProxySignals.getInstance().userexitroomSignal.dispatch();
		}
		
		public function matchover(params:Object):void
		{
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.matchoverSignal.dispatch();
		}
		
		public function tolobbyongameexit(params:Object):void
		{
			var kickout:int 		= params.params.getInt("kickout");
			var gameView:GameView 	= SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.tolobbyongameexitSignal.dispatch(kickout);
		}	
		
		public function KickOut(params:Object):void
		{
			var gameView:GameView 	= SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.joinFailureOnRoomFullSignal.dispatch();
		}
		
		public function spectatornotification(params:Object):void
		{
			var game:IGame 				= fetchGameType(params.params);
			var match:MatchImpl 		= params.params.getClass("MatchImpl");
			//var seatId:int 				= params.params.getInt("seatid");
			var deal:DealImpl 			= params.params.getClass("DealImpl");
			//var handCards:HandCardsImpl = params.params.getClass("HandCardsImpl"); // need to check coming from server
			var minBuyIn:int 			= params.params.getInt("minbuyin");
			var turnTimeRemaining:int 	= params.params.getInt("turnticker");
			var turnTimerSeatId:int 	= params.params.getInt("turntimerseatid");
			var displayId:String 		= params.params.getUtfString("displayid");
			//var seatImpl:SeatImpl 		= params.params.getClass("SeatImpl");
			var player:PlayerImpl		= params.params.getClass("PlayerImpl");
			var showTicker:int			= params.params.getInt("showticker");
			var showInitTicker:int		= params.params.getInt("showinitticker");
			var scoreCardTicker:int		= params.params.getInt("scorecardticker");
			var isShowSubmitted:Boolean = params.params.getBool("showsubmit");
			var isShowInitiator:Boolean = params.params.getBool("showinitiator");
			var openDeck:OpenDeckImpl	= params.params.getClass("OpenDeckImpl");
			var currentOpenCardTurn:int	= params.params.getInt("currentturn");
			var roundCount:int 			= params.params.getInt("roundcount");
			
			
			/*if(handCards)
			{
				var cards:Array				= GroupCardsImpl(handCards.groupcards[0]).card;
				var pickedCard:CardImpl;
				// if the player picked the card and closes his/her browser and joins from the my table
				// then server will give 14 cards and the last card will be the last picked card
				if(cards.length == 14)
				{
					pickedCard	= cards[cards.length-1];
					handCards.groupcards[0].card.splice(13, 1)
				}
			}*/
			
			var joker:CardImpl			= null;
			var discardedCard:CardImpl	= null;
			
			if(scoreCardTicker >0)
				joker					= params.params.getClass("CardImpl");
			else
				discardedCard			= params.params.getClass("CardImpl");
			
			var matchSettlement:MatchSettlementImpl = params.params.getClass("MatchSettlementImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
			{
				var data:Object			= {};
				data.game				= game;
				//data.seatId				= seatId;
				data.match				= match;
				data.deal				= deal;
				//data.handCards			= handCards;
				data.minBuyIn			= minBuyIn;
				data.turnTimeRemaining	= turnTimeRemaining;
				data.turnTimerSeatId	= turnTimerSeatId;
				data.displayId			= displayId;
				//data.seatImpl			= seatImpl;
				data.player				= player;
				data.showTicker			= showTicker;
				data.showInitTicker		= showInitTicker;
				data.matchSettlement	= matchSettlement;
				data.scoreCardTicker	= scoreCardTicker;
				data.joker				= joker;
				data.discardedCard		= discardedCard;
				data.isShowSubmitted	= isShowSubmitted;
				data.isShowInitiator	= isShowInitiator;
				//data.pickedCard			= pickedCard;
				data.openDeck			= openDeck;
				data.currentOpenCardTurn= currentOpenCardTurn;
				data.roundCount			= roundCount;
				
				gameView.spectatorNotificationSignal.dispatch(data);// (game, seatId, match, deal, handCards, minBuyIn, turnTimeRemaining, turnTimerSeatId, displayId);
			}
		}
		
	}
}