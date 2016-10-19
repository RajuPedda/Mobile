package utils
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * The <code>Scale9Sprte</code> class allows for an image
	 * to be scaled without scaling the corners; this is helpful
	 * when scaling rounded rectangles in order to keep the radius
	 * on the corners square and constant size.
	 * */
	public class NineSliceSprite extends Sprite{
		/**
		 * An array of <code>BitmapData</code> objects that are the
		 * nine slices of the image.
		 * 
		 * @private
		 * */
		private var slices:Array;
		
		/**
		 * The width of the image.
		 * 
		 * @private
		 * */
		private var mWidth:Number;
		
		/**
		 * The height of the image.
		 * 
		 * @private
		 * */
		private var mHeight:Number;
		
		/**
		 * Creates a new <code>Scale9Sprite</code> instance whose image
		 * is contained in <code>data</code> and whose center slice is
		 * <code>rect</code>.
		 * 
		 * @param data The image to display
		 * @param rect The center slice
		 * */
		public function NineSliceSprite(data:BitmapData, rect:Rectangle){
			super();
			slices = new Array();
			//set initial width and height
			mWidth = data.width;
			mHeight = data.height;
			var bd:BitmapData;
			//create the nine slices, and store in the array
			bd = new BitmapData(rect.x, rect.y, true, 0x00000000);//top left
			bd.copyPixels(data, new Rectangle(0, 0, rect.x, rect.y), new Point(0, 0));
			slices.push(bd);
			bd = new BitmapData(rect.width, rect.y, true, 0x00000000);//top center
			bd.copyPixels(data, new Rectangle(rect.x, 0, rect.width, rect.y), new Point(0, 0));
			slices.push(bd);
			bd = new BitmapData(data.width - rect.right, rect.y, true, 0x00000000);//top right
			bd.copyPixels(data, new Rectangle(rect.right, 0, data.width - rect.right, rect.y), new Point(0, 0));
			slices.push(bd);
			bd = new BitmapData(rect.x, rect.height, true, 0x00000000);//middle left
			bd.copyPixels(data, new Rectangle(0, rect.y, rect.x, rect.height), new Point(0, 0));
			slices.push(bd);
			bd = new BitmapData(rect.width, rect.height, true, 0x00000000);//center
			bd.copyPixels(data, new Rectangle(rect.x, rect.y, rect.width, rect.height), new Point(0, 0));
			slices.push(bd);
			bd = new BitmapData(data.width - rect.width, rect.height, true, 0x00000000);//middle right
			bd.copyPixels(data, new Rectangle(rect.right, rect.y, data.width - rect.right, rect.height), new Point(0, 0));
			slices.push(bd);
			bd = new BitmapData(rect.x, data.height - rect.bottom, true, 0x00000000);//bottom left
			bd.copyPixels(data, new Rectangle(0, rect.bottom, rect.x, data.height - rect.bottom), new Point(0, 0));
			slices.push(bd);
			bd = new BitmapData(rect.width, data.height - rect.bottom, true, 0x00000000);//bottom center
			bd.copyPixels(data, new Rectangle(rect.x, rect.bottom, rect.width, data.height - rect.bottom), new Point(0, 0));
			slices.push(bd);
			bd = new BitmapData(data.width - rect.right, data.height - rect.bottom, true, 0x00000000);//bottom right
			bd.copyPixels(data, new Rectangle(rect.right, rect.bottom, data.width - rect.right, data.height - rect.bottom), new Point(0, 0));
			slices.push(bd);
			//position the slices, and add them to the image
			for(var i:int = 0; i < 9; i++){
				var img:Image = new Image(Texture.fromBitmapData(slices[i]));
				switch(i % 3){
					case 1:
						img.x = rect.x;
						break;
					case 2:
						img.x = rect.right;
						break;
				}
				switch(Math.floor(i / 3)){
					case 1:
						img.y = rect.y;
						break;
					case 2:
						img.y = rect.bottom;
						break;
				}
				slices[i] = img;
				this.addChild(img);
			}
		}
		
		/**
		 * The width of the image.
		 * */
		public override function set width(value:Number):void{
			if(value < slices[0].width + slices[2].width){
				throw new Error("Invalid Argument.");
			}
			slices[1].width = slices[4].width = slices[7].width = value - slices[0].width - slices[2].width + 1;
			slices[2].x = slices[5].x = slices[8].x = value - slices[2].width;
			mWidth = value;
		}
		
		public override function get width():Number{
			return mWidth;
		}
		
		/**
		 * The height of the image.
		 * */
		public override function set height(value:Number):void{
			if(value < slices[0].height + slices[6].width){
				throw new Error("Invalid Argument.");
			}
			slices[3].height = slices[4].height = slices[5].height = value - slices[0].height - slices[6].height + 2;
			slices[6].y = slices[7].y = slices[8].y = value - slices[6].height;
			mHeight = value;
		}
		
		public override function get height():Number{
			return mHeight;
		}
	}
}