package com.mangogames.views.game
{
	import com.mangogames.views.mediators.AbstractBaseMediator;
	
	public class GameMediator extends AbstractBaseMediator
	{
		public function GameMediator(view:GameView)
		{
			super();
		}
		
		public function dispose():void
		{
			super.cleanup();
		}
	}
}