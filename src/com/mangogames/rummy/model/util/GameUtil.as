package com.mangogames.rummy.model.util
{
	import com.mangogames.models.IGame;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.SeatImpl;

	public class GameUtil
	{
		public function GameUtil()
		{
		}
		
		public static function getPlayerById(game:IGame, userId:int):PlayerImpl
		{
			if(game && game.seat)
			{
				var len:int = game.seat.length;
				var gamePlayer:PlayerImpl;
				
				for(var i:int=0; i<len; i++)
				{
					gamePlayer =  (game.seat[i] as SeatImpl).player;
					if(gamePlayer && gamePlayer.id == userId)
						return gamePlayer;
				}
			}
			return null;
		}
		
		public static function getPlayerBySeatId(game:IGame, seatId:int):PlayerImpl
		{
			var seat:SeatImpl = getSeatBySeatId(game, seatId);
			var gamePlayer:PlayerImpl;
			
			if(seat && seat.player)
			{
				gamePlayer = seat.player;
				return gamePlayer;					
			}
			return null;
		}
		
		public static function getSeatBySeatId(game:IGame, seatId:int):SeatImpl
		{
			if(game && game.seat)
			{
				var len:int = game.seat.length;
				var seat:SeatImpl;
				
				for(var i:int=0; i<len; i++)
				{
					seat =  (game.seat[i] as SeatImpl)
					if(seat.seatId == seatId)
						return seat;
				}
			}
			
			return null;
		}
		
		public static function getSeatByPlayerId(game:IGame, userId:int):SeatImpl
		{
			if(game && game.seat)
			{
				var len:int = game.seat.length;
				var seat:SeatImpl;
				
				for(var i:int=0; i<len; i++)
				{
					seat =  (game.seat[i] as SeatImpl)
					if( seat.player && seat.player.id == userId)
						return seat;
				}
			}
			return null;
		}
		
		public static function updateGamePlayer(game:IGame, gamePlayer:PlayerImpl):Boolean
		{
			if(game && game.seat)
			{
				var len:int = game.seat.length;
				var temp:SeatImpl;
				
				for(var i:int=0; i<len; i++)
				{
					temp =  (game.seat[i] as SeatImpl);
					if(temp.player && temp.player.id == gamePlayer.id)
					{
						temp.player = gamePlayer;
						return true;
					}
				}
			}
			return false;
		}
		
		public static function getRelativeSeatPosition(seatId:int, mySeatId:int, totalSeatCount:int):int
		{
			// "me" should be seating at the 0th position regardless of position
			// given by server, all the other players will be shifted accordingly
			var offset:int = totalSeatCount - mySeatId;
			var relPos:int = seatId + offset;
			
			if (relPos == totalSeatCount)
				return 0;
			else if (relPos < totalSeatCount)
				return relPos;
			else if (relPos > totalSeatCount)
				return relPos - totalSeatCount;
			
			throw new Error("how come you can reach here!?");
		}
	}
}