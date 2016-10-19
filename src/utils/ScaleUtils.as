package utils
{
	import com.mangogames.views.AbstractBaseView;
	
	import flash.display.Stage;
	
	import logger.Logger;
	
	import starling.display.DisplayObject;
	
	public class ScaleUtils
	{
		private static var _scaleFactorNoClipping:Number;
		private static var _scaleFactorNoBorder:Number;
		
		private static var STAGE_WIDTH:int;
		private static var STAGE_HEIGHT:int;
		
		public static function calculateBestScaleFactor(stage:Stage):void
		{
			const targetWidth:Number = stage.fullScreenWidth;
			const targetHeight:Number = stage.fullScreenHeight;
			
			const contentWidth:Number = Constants.CONTENT_WIDTH;
			const contentHeight:Number = Constants.CONTENT_HEIGHT;
			
			// we will start with width, first we shall get the width ratio if we are scaling
			var ratio:Number = targetWidth / contentWidth;
			_scaleFactorNoBorder = ratio; // FIXME: calculate properly
			
			// now we shall check whether multipying height with this ratio will
			// make the content height bigger than target width.
			// if the height is bigger than we recalculate the ratio
			// and adjust it as per height
			if (ratio * contentHeight > targetHeight)
			{
				ratio = targetHeight / contentHeight;
			}
			
			// now we have the final ratio that we may use as scale factor
			_scaleFactorNoClipping = ratio;
			Logger.log("scale factor is set to: " + _scaleFactorNoClipping);
		}
		
		public static function applyNoBorderScale(object:DisplayObject):void
		{
			object.scaleX = _scaleFactorNoBorder;
			object.scaleY = _scaleFactorNoBorder;
			
			//object.width = object.width * _scaleFactorNoBorder;
			//object.height = object.height * _scaleFactorNoBorder;//_scaleFactorNoBorder;
		}
		
		public static function applyNoClippingScale(object:DisplayObject):void
		{
			object.scaleX = _scaleFactorNoClipping;
			object.scaleY = _scaleFactorNoClipping;
		}
		
		public static function applyScale(object:DisplayObject, scaleType:String):void
		{
			switch (scaleType)
			{
				case ScaleType.NO_BORDER:
					applyNoBorderScale(object);
					break;
				
				case ScaleType.NO_CLIPPING:
					applyNoClippingScale(object);
					break;
			}
		}
		
		public static function applyPercentageScale(displayObj:DisplayObject, xPercentage:int, yPercentage:int):DisplayObject
		{
			if(STAGE_WIDTH <= 0)
			{
				var obj:Object	= AbstractBaseView.getStageSize();
				STAGE_WIDTH		= obj.stageWidth;
				STAGE_HEIGHT	= obj.stageHeight;
			}
			displayObj.width	= (STAGE_WIDTH*xPercentage)/100;
			displayObj.height	= (STAGE_HEIGHT*yPercentage)/100;
			
			return displayObj;
		}
		
		public static function layoutChildrenBasedOnMeasure(displayObj:DisplayObject, x:int, y:int):DisplayObject
		{
			
			return displayObj;
		}
		
		public static function get scaleFactorNoClipping():Number { return _scaleFactorNoClipping; }
		public static function get scaleFactorNoBorder():Number { return _scaleFactorNoBorder; }
	}
}