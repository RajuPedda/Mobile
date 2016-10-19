package com.mangogames.views
{
	import feathers.controls.Screen;
	
	import starling.core.Starling;

	public class AbstractBaseView extends Screen
	{
		public static var STAGE_WIDTH:int;
		public static var STAGE_HEIGHT:int;
		
		protected const PADDING:int = 30;
		protected const GAPING:int = 10;
		
		public function AbstractBaseView()
		{
		}
		
		public static function setStageSize():void
		{
			STAGE_WIDTH = Starling.current.stage.stageWidth;
			STAGE_HEIGHT = Starling.current.stage.stageHeight;
		}
		
		public static function getStageSize():Object
		{
			var obj:Object	= {};
			obj.stageWidth	= STAGE_WIDTH;
			obj.stageHeight	= STAGE_HEIGHT;
			return obj;
		}
		
	}
}