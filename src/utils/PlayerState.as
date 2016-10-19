package utils
{
	public class PlayerState
	{
		public static var WAITING_TO_START:int = -1;
		public static var READY_TO_PLAY:int = 0;
		public static var PLAYING:int = 1;
		public static var WINNER:int = 2;
		public static var KICKED_OUT:int = 3;
		public static var GONE:int = 4;
		public static var DROPPED:int = 5;
		public static var INVALID_SHOW:int = 6;
		public static var FIRST_DROP:int = 7;
		public static var MIDDLE_DROP:int = 8;
		public static var DONE_WITH_SHOW:int = 9;
		public static var DEAL_PLAYER_GONE:int	= 512;
		
		public static function toString(state:int):String
		{
			switch (state)
			{
				case WAITING_TO_START: return "Lose";
				case READY_TO_PLAY: return "Lose";
				case PLAYING: return "Lose";
				case WINNER: return "Winner";
				case KICKED_OUT: return "Lose";
				case GONE: return "Lose";
				case DROPPED: return "Drop";
				case INVALID_SHOW: return "Wrong Show";
				case FIRST_DROP: return "Drop";
				case MIDDLE_DROP: return "Middle Drop";
				case DEAL_PLAYER_GONE: return "Lose";
				case DONE_WITH_SHOW: return "Lose";
			}
			return "";
		}
	}
}