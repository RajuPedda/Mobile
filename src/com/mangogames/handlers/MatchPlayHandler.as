package com.mangogames.handlers
{
	import com.mangogames.rummy.model.impl.CardImpl;
	import com.mangogames.rummy.model.impl.HandCardsImpl;
	import com.mangogames.rummy.model.impl.MatchImpl;
	import com.mangogames.rummy.model.impl.MatchSettlementImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.SeatRearranementImpl;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.game.GameView;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.invitation.SFSInvitation;
	
	public class MatchPlayHandler extends AbstractBaseHandler
	{
		public function MatchPlayHandler()
		{
			super();
		}
		
		public function turnover(params:Object):void
		{
			var seatId:int = params.params.getInt("seatid");
			var timeOut:int = params.params.getInt("timeout");
			trace("Open SeatId = " + seatId);
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.turnoverSignal.dispatch(seatId, timeOut);
		}
		
		public function playerleft(params:Object ):void
		{
			var seatId:Number = params.params.getInt("SeatID");
			var playerId:int = params.params.getLong("playerid");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.playerleftSignal.dispatch(seatId, playerId);
			// to update the lobby view
			//ProxySignals.getInstance().playerLeftNotifierSignal.dispatch(playerId);
		}
		
		public function playergone(params:Object):void
		{
			var seatId:Number = params.params.getInt("SeatID");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.playergoneSignal.dispatch(seatId);
		}
		
		public function playerdropped(params:Object):void
		{
			var seatId:int 			= params.params.getInt("seatid");
			var penaltyScore:int 	= params.params.getInt("droppenalty");
			var playerId:int 		= params.params.getLong("playerid");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.playerdroppedSingnal.dispatch(seatId, playerId, penaltyScore);
		}
		
		public function sfsinvitation(params:Object):void
		{
			var sfsInvite:SFSInvitation = params.params.getClass("SFSInvitation");
			
			ProxySignals.getInstance().sfsinvitationSignal.dispatch(sfsInvite);
		}
		
		public function playerpickedcard(params:Object):void
		{
			var playerId:int = params.params.getInt("playerid");
			var pickedFrom:int = params.params.getInt("pickedfrom");
			var pickedCard:CardImpl	= params.params.getClass("CardImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.playerpickedcardSignal.dispatch(playerId, pickedFrom, pickedCard);
		}
		
		public function newcardreceived(params:Object):void
		{
			var pickedFrom:int = params.params.getInt("PickedFrom");
			var playerId:int = params.params.getInt("playerid");
			var seatId:int = params.params.getInt("seatid");
			var newCard:CardImpl = params.params.getClass("CardImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.newcardreceivedSignal.dispatch(seatId, pickedFrom, newCard);
		}
		
		public function discardedcard(params:Object):void
		{
			var seatId:int = params.params.getInt("seatid");
			var wasTurnMissed:Boolean = params.params.getBool("WasTurnMissed");
			var card:CardImpl = params.params.getClass("CardImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.discardedcardSignal.dispatch(seatId, wasTurnMissed, card);
		}
		
		public function pickerror(params:Object):void
		{
			var messageCode:int = params.params.getInt("messagecode");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.pickerrorSignal.dispatch(messageCode);
		}
		
		public function showinitiated(params:Object):void
		{
			var seatId:int = params.params.getInt("seatid");
			var timeout:int = params.params.getInt("timeout");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.showinitiatedSignal.dispatch(seatId, timeout);
		}
		
		public function invalidshow(params:Object):void
		{
			var playerId:int = params.params.getInt("playerid");
			var discardedCard:CardImpl = params.params.getClass("CardImpl");
			var wrongPenalty:int = params.params.getInt("wrongpenalty");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.invalidshowSignal.dispatch(playerId, discardedCard, wrongPenalty);
		}
		
		public function gameovershowsettlement(params:Object):void
		{
			var seatId:int = params.params.getInt("seatid");
			var timeout:int = params.params.getInt("timeout");
			var score:int = params.params.getInt("score");
			var leftPlayersList:SFSArray	= params.params.getSFSArray("droppedplayers");
			var handCards:HandCardsImpl		= params.params.getClass("HandCardsImpl");
			var totalScore:int				= params.params.getInt("totalscore");
			var totalPlayers:SFSArray		=  params.params.getSFSArray("alldealplayers");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.gameoverSettlementSignal.dispatch(seatId, timeout, score, totalPlayers, handCards, totalScore);
		}
		
		public function gameovershowcards(params:Object):void
		{
			var seatId:int = params.params.getInt("seatid");
			var timeout:int = params.params.getInt("timeout");
			var score:int = params.params.getInt("score");
			var leftPlayersList:SFSArray	= params.params.getSFSArray("droppedplayers");
			var handCards:HandCardsImpl		= params.params.getClass("HandCardsImpl");
			var totalScore:int				= params.params.getInt("totalscore");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.gameovershowcardsSignal.dispatch(seatId, timeout, score, leftPlayersList, handCards, totalScore);
		}
		
		public function matchresults(params:Object):void
		{
			var match:MatchImpl = params.params.getClass("MatchImpl");
			var matchSettlement:MatchSettlementImpl = params.params.getClass("MatchSettlementImpl");
			var timer:int = params.params.getInt("timer");
			var displayGameId:String = params.params.getUtfString("displayid");
			
			var matchDeclared:Boolean	= params.params.getBool("matchtie");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.matchsettlementSignal.dispatch(match, matchSettlement, timer, displayGameId, matchDeclared);
		}
		
		public function buyinsuccess(params:Object):void
		{
			var player:PlayerImpl = params.params.getClass("PlayerImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.buyinsuccessSignal.dispatch(player);
		}
		
		public function buyinerror(params:Object):void
		{
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.buyinerrorSignal.dispatch();
		}
		
		public function oppbuyin(params:Object):void
		{
			var playerId:int = params.params.getInt("playerid");
			var amount:int = params.params.getInt("amount");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.oppbuyinSignal.dispatch(playerId, amount);
		}
		
		public function srejoin(params:Object):void
		{
			var playerId:int = params.params.getLong("playerid");
			var highestPoints:int = params.params.getInt("highestpoints");
			var forceExit:int = params.params.getInt("forceexit");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.rejoinSignal.dispatch(playerId, highestPoints, forceExit);
		}
		
		public function rejoinresp(params:Object):void
		{
			var playerId:int = params.params.getLong("playerid");
			var highestPoints:int = params.params.getInt("highestpoints");
			var seatId:int = params.params.getInt("seatId");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.rejoinrespSignal.dispatch(playerId, highestPoints, seatId);
		}
		
		public function reshuffle(params:Object):void
		{
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.reshuffleSignal.dispatch();
		}
		
		public function autosplit(params:Object):void
		{
			var windrop:int = params.params.getInt("windrop");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.autosplitSignal.dispatch(windrop);
		}
		
		public function seatshuffle(params:Object):void
		{
			var seatArrangement:SeatRearranementImpl = params.params.getClass("SeatRearranementImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.seatsuffleSignal.dispatch(seatArrangement.seat);
		}
		
		public function manualsplitenable(params:Object):void
		{
			var splitAmounts:Array = SFSArray(params.params.getSFSArray("splitamounts")).toArray();
			var timer:int = params.params.getInt("timer");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.manualSplitEnabled.dispatch(splitAmounts, timer);
		}
		
		public function manualsplitaccepted(params:Object):void
		{
			var timeout:int = params.params.getInt("timeout");
			var playerId:int = params.params.getInt("playerid");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.manualSplitAcceptedSignal.dispatch(timeout, playerId);
		}
		
		public function manualsplitresult(params:Object):void
		{
			var splitdistribution:int = params.params.getInt("splitdistribution");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.manualSplitResultSignal.dispatch(splitdistribution);
		}
		
		public function leavetableresponse(params:Object):void
		{
			var playerId:int = params.params.getLong("playerId");
			var seatId:int = params.params.getLong("seatId");
			var leaveTablePenalty:int = params.params.getLong("leavetablepenalty");
			var playersCount:int = params.params.getInt("playerscount");
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.leaveTableResponseSignal.dispatch(playerId, seatId, leaveTablePenalty, playersCount);
		}
		
		public function CardsShownDone(params:Object):void
		{
			var seatNo:int 					= params.params.getInt("SeatNo");
			var score:int 					= params.params.getInt("score");
			var playerId:int 				= params.params.getLong("playerid");
			var handCards:HandCardsImpl		= params.params.getClass("HandCardsImpl");
			var wonOrLoss:int				= params.params.getLong("wonorloss");
			var dealPlayers:SFSArray		= params.params.getSFSArray("alldealplayers");
			
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.cardsShownDoneSignal.dispatch(seatNo, playerId, score, handCards, wonOrLoss, dealPlayers);
		}
		
		public function reentry(params:Object):void
		{
			var playerId:int 	= params.params.getLong("playerid");
			var seatId:int 		= params.params.getLong("seatid");
			var amount:int		= params.params.getLong("amount");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.reentrySignal.dispatch(playerId, seatId, amount);
		}
		
		public function rejoinseatshuffle(params:Object):void
		{
			var seatArrangement:SeatRearranementImpl = params.params.getClass("SeatRearranementImpl");
			var isRejoined:Boolean = params.params.getBool("isrejoined");
			var leftPlayers:Array	= params.params.getLongArray("leftplayers");
			var matchImpl: MatchImpl = params.params.getClass("MatchImpl");
			
			var gameView:GameView = SFSInterface.getInstance().getGameRoom(params.sourceRoom).gameView;
			if (gameView)
				gameView.rejoinSeatsuffleSignal.dispatch(seatArrangement.seat, isRejoined, leftPlayers, matchImpl);
		}
	}
}