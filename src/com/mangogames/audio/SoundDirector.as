package com.mangogames.audio
{
	import com.mangogames.managers.MangoAssetManager;
	
	import utils.SoundManager;
	
	
	public class SoundDirector extends SoundManager
	{
		private static var _instance:SoundDirector;
		
		private var bSoundsInitd:Boolean;
		
		public static var DINGDONG:String = "beep-04"; //player joined
		public static var CARD_SHUFFLESLOW:String = "shuffling-cards-4";
		public static var GAME_WINNER:String = "applause-01";
		public static var PICK_DISCARD:String = "page-flip-16";
		public static var HEARTBEAT:String = "Hearbeat_2";
		
		public function SoundDirector()
		{
			super();
			bSoundsInitd = false;
		}
		
		// -------------------------------------------------------------------------------------------------------------------------		
		public static function getInstance():SoundDirector
		{
			if (!_instance)
			{
				_instance = new SoundDirector();
			}			
			
			return _instance;
		}
		// -------------------------------------------------------------------------------------------------------------------------
		
		
		
		/**
		 * Add all the assets here.
		 */
		public function initAllSounds():void
		{
			if( bSoundsInitd == false )
			{
				addSound(DINGDONG, MangoAssetManager.I.getSound(DINGDONG));
				addSound(CARD_SHUFFLESLOW, MangoAssetManager.I.getSound(CARD_SHUFFLESLOW));
				addSound(GAME_WINNER, MangoAssetManager.I.getSound(GAME_WINNER));
				addSound(PICK_DISCARD, MangoAssetManager.I.getSound(PICK_DISCARD));
				addSound(HEARTBEAT, MangoAssetManager.I.getSound(HEARTBEAT));
			}
			
			bSoundsInitd = true;
		}
		
		
		override public function stopSound(id:String):void
		{
			if(soundIsPlaying(id))
			{
				super.stopSound(id);
			}
		}

	}
}