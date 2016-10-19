package com.mangogames.rummy.model.util
{
	import com.mangogames.rummy.model.impl.MatchImpl;
	import com.mangogames.rummy.model.impl.MatchPlayerImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	
	/**
	 * @author Raju.M
	 * 
	 */
	public class MatchUtil
	{
		public function MatchUtil()
		{
		}
		
		public static function updateMatchPlayer(match:MatchImpl, matchPlayer:MatchPlayerImpl):Boolean
		{
			if(match && matchPlayer)
			{
				var len:int = match.matchplayer.length;
				var temp:MatchPlayerImpl;
				
				for(var i:int=0; i<len; i++)
				{
					temp = match.matchplayer[i];
					if(temp.dbId == matchPlayer.dbId)
					{
						match.matchplayer[i] = matchPlayer;
						return true;
					}
				}
			}
			
			return false;
		}
		
		public static function getMatchPlayerById(playerId:int):MatchPlayerImpl
		{
			var match:MatchImpl = MainModel.getInstance().matchImpl;
			if(match && match.matchplayer)
			{
				var len:int = match.matchplayer.length;
				var matchPlayer:MatchPlayerImpl;
				
				for(var i:int =0; i<len; i++)
				{
					matchPlayer = match.matchplayer[i];
					if(matchPlayer && matchPlayer.dbId == playerId)
						return matchPlayer;
				}
			}
			return null;
		}
		
		public static function getMatchPlayerBySeatId(seatId:int):MatchPlayerImpl
		{
			var gamePlayer:PlayerImpl = GameUtil.getPlayerBySeatId(seatId);
			var matchPlayer:MatchPlayerImpl;
			
			if(gamePlayer)
			{
				matchPlayer = getMatchPlayerById(gamePlayer.id);
				return matchPlayer;
			}
			
			return null;
		}
	}
}