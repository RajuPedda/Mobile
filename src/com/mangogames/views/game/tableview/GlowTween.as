package com.mangogames.views.game.tableview
{
	import starling.animation.IAnimatable;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.filters.GlowFilter;
	import starling.utils.Color;
	
	public class GlowTween implements IAnimatable
	{
		private var _target:Sprite;
		private var _glowFactor:Number;
		private var _inverse:Boolean;
		
		public function GlowTween(target:Sprite)
		{
			_target = target;
			_glowFactor = 0;
		}
		
		public function advanceTime(time:Number):void
		{
			if (!_target)
				return;
			
			if (_glowFactor > 1)
				_inverse = true;
			else if (_glowFactor < 0)
				_inverse = false;
			
			_glowFactor += _inverse ? time : -time;
			var glowFilter:GlowFilter	= new GlowFilter(Color.RED);
			_target.filter = glowFilter; //BlurFilter.createGlow(Color.RED, 1, 2, 1);
		}
		
		public function dispose():void
		{
			_target.filter = null;
			_target = null;
		}
	}
}