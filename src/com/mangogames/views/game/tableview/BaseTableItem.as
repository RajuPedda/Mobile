package com.mangogames.views.game.tableview
{
	import starling.display.Sprite;
	import starling.filters.GlowFilter;
	
	public class BaseTableItem extends Sprite
	{
		private var _tween:GlowTween;
		
		public function BaseTableItem()
		{
			super();
		}
		
		public function startGlow():void
		{
			var glowFilter:GlowFilter	= new GlowFilter();
			filter = glowFilter; //BlurFilter.createGlow(16776960, 1, 2, 1);
			//trace (">>>starting glow for: " + _tween);
			
			// FIXME: this is causing a crash in next frame render, commenting it for now
			//_tween = new GlowTween(this);
			//Starling.juggler.add(_tween);
		}
		
		public function stopGlow():void
		{
			filter = null;
			
			if (!_tween)
				return;
			
			_tween.dispose();
		}
	}
}