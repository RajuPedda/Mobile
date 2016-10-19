package utils
{
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;

	public class DrawShapeUtil
	{
		public static function getBoxWithBorder(ww:int, hh:int, plainColor:int = 0xFF00FF, borderColor:int = 0xFFFFFF, borderThickness:int = 2):QuadBatch 
		{
			// create batch
			var result : QuadBatch = new QuadBatch();
			
			// create plain color
			var center : Quad = new Quad(ww, hh, plainColor);
			center.alpha = 0.5
			
			// create borders
			var left : Quad = new Quad(borderThickness, hh, borderColor);
			var right : Quad = new Quad(borderThickness, hh, borderColor);
			
			var top : Quad = new Quad(ww, borderThickness, borderColor);
			var down : Quad = new Quad(ww, borderThickness, borderColor);
			
			// placing elements (top and left already placed)
			right.x = ww - borderThickness;
			down.y = hh - borderThickness;
			
			// build box
			result.addQuad(center);
			result.addQuad(left);
			result.addQuad(top);
			result.addQuad(right);
			result.addQuad(down);	
			
			return result;
		}
		
		public static function getBoxWithBorderWithSprite(ww:int, hh:int, plainColor:int = 0xFF00FF, borderColor:int = 0xFFFFFF, borderThickness:int = 2):Sprite 
		{
			// create batch
			var result : Sprite = new Sprite();
			
			// create plain color
			var center : Quad = new Quad(ww, hh, plainColor);
			center.alpha = 0.5
			
			// create borders
			var left : Quad = new Quad(borderThickness, hh, borderColor);
			var right : Quad = new Quad(borderThickness, hh, borderColor);
			
			var top : Quad = new Quad(ww, borderThickness, borderColor);
			var down : Quad = new Quad(ww, borderThickness, borderColor);
			
			// placing elements (top and left already placed)
			right.x = ww - borderThickness;
			down.y = hh - borderThickness;
			
			// build box
			result.addChild(center);
			result.addChild(left);
			result.addChild(top);
			result.addChild(right);
			result.addChild(down);	
			
			return result;
		}
	}
}