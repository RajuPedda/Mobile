package utils
{
	
	import com.mangogames.managers.MangoAssetManager;
	
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import feathers.controls.Header;
	import feathers.controls.TextInput;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	
	public class ControlUtils
	{
		public static function createButton(textureName:String, label:String, scaleType:String = ScaleType.NONE):Button
		{
			var button:Button = new Button(MangoAssetManager.I.getTexture(textureName), label);
			button.textFormat.font = FontUtils.FONTFAMILY_ARIAL_ROUNDED;
			button.textFormat.bold = true;
			button.textFormat.color = Color.WHITE;
			button.textFormat.size = FontUtils.FONTSIZE_SMALL;
			
			if (scaleType != ScaleType.NONE)
				ScaleUtils.applyScale(button, scaleType);
			
			return button;
		}
		
		public static function createTextInput(scaleType:String = ScaleType.NONE, maxChars:int=9):TextInput
		{
			// add a input box
			var texture:Texture = MangoAssetManager.I.getTexture("type_box");
			//var scale9Texture:Scale9Textures = new Scale9Textures(texture, new Rectangle(5, 5, 22, 22));
			var txiInput:TextInput = new TextInput();
			/*txiInput.textEditorFactory = function():ITextEditor
			{
				var editor:StageTextTextEditor = new StageTextTextEditor();
				editor.fontFamily = FontUtils.FONTFAMILY_ARIAL_ROUNDED;
				editor.fontSize = FontUtils.FONTSIZE_LARGE;
				editor.color = Color.BLACK;
				editor.textAlign = TextFormatAlign.CENTER;
				return editor;
			}*/
			/*txiInput.backgroundSkin = new Scale9Image(scale9Texture);
			
			txiInput.backgroundSkin = new Scale9Image( scale9Texture );
			txiInput.backgroundDisabledSkin = new Scale9Image( scale9Texture );
			txiInput.backgroundFocusedSkin = new Scale9Image( scale9Texture );*/
			
			
			txiInput.paddingTop = 0;
			txiInput.maxChars = maxChars;
			
			if (scaleType != ScaleType.NONE)
				ScaleUtils.applyScale(txiInput, scaleType);
			
			return txiInput;
		}
		
		public static function createCenteredLabel(text:String, scaleType:String = ScaleType.NONE, desiredWidth:int = 1):TextField
		{
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, Fonts.getInstance().mediumFont, Color.WHITE);
			var txtLabel:TextField = new TextField(desiredWidth, 1, text, tf);
			txtLabel.autoSize = desiredWidth == 1 ? TextFieldAutoSize.BOTH_DIRECTIONS : TextFieldAutoSize.VERTICAL;
			txtLabel.touchable = false;
			
			if (scaleType != ScaleType.NONE)
				ScaleUtils.applyScale(txtLabel, scaleType);
			
			return txtLabel;
		}
		
		public static function drawPieMask(shape:Shape, percentage:Number, radius:Number = 50, x:Number = 0, y:Number = 0, rotation:Number = 0, sides:int = 8):void
		{
			shape.graphics.clear();
			shape.graphics.beginFill(0xffffff);
			shape.graphics.moveTo(x, y);
			if (sides < 3)
				sides = 3; // 3 sides minimum
			
			// increase the length of the radius to cover the whole target
			radius /= Math.cos(1 / sides * Math.PI);
			
			// find how many sides we have to draw
			var sidesToDraw:int = Math.floor(percentage * sides);
			
			for (var i:int = 0; i <= sidesToDraw; i++)
				lineToRadians((i / sides) * (Math.PI * 2) + rotation);
			
			// draw the last fractioned side
			if (percentage * sides != sidesToDraw)
				lineToRadians(percentage * (Math.PI * 2) + rotation);
			
			shape.graphics.endFill();
			
			// shortcut function
			function lineToRadians(rads:Number):void
			{
				shape.graphics.lineTo(Math.cos(rads) * radius + x, Math.sin(rads) * radius + y);
			};
		}
		
		public static function popUpOverlayFactory():DisplayObject
		{
			const quad:Quad = new Quad(100, 100, 0x1a1816);
			quad.alpha = 0.75;
			return quad;
		}
		
		public static function popUpAnimatedOverlayFactory():DisplayObject
		{
			const quad:Quad = new Quad(100, 100, 0x1a1816);
			quad.alpha = 0;
			
			var tween:Tween = new Tween(quad, 0.6, Transitions.EASE_OUT);
			tween.animate("alpha", 0.75);
			Starling.juggler.add(tween);
			
			return quad;
		}
		
		public static function popUpBlackOverlayFactory():DisplayObject
		{
			const quad:Quad = new Quad(100, 100, 0x0);
			quad.alpha = 1;
			return quad;
		}
		
		public static function createRoundClippedImage(sourceImage:Image, mask:Image):Image
		{
			// prepare the clipper
			mask.blendMode = BlendMode.ERASE;
			
			// adjust source image
			sourceImage.width = mask.width;
			sourceImage.height = mask.height;
			
			// prepare the resultant texture
			var buffer:RenderTexture = new RenderTexture(sourceImage.width, sourceImage.height, false);
			buffer.drawBundled(drawElements);
			
			return new Image(buffer);
			
			function drawElements():void
			{
				buffer.draw(sourceImage);
				buffer.draw(mask);
			}
		}
		
		public static function createHeader(title:String, width:int, height:int):Header
		{
			var header:Header = new Header();
			header.width = width;
			header.height = height;
			var img:Image	= new Image(MangoAssetManager.I.getTexture("black_bg"));
			img.scale9Grid	= new Rectangle(4, 4, 8, 8);
			header.backgroundSkin = img; //new Scale9Image(new Scale9Textures(MangoAssetManager.I.getTexture("black_bg"), new Rectangle(4, 4, 8, 8)));
			header.title = title;
			header.padding = 5;
			header.titleAlign = Header.TITLE_ALIGN_CENTER;
			return header;
		}
		
		public static function createHighlightBg(width:int, height:int):Image
		{
			var img:Image	= new Image(MangoAssetManager.I.getTexture("sorted_bg"));
			img.scale9Grid	= new Rectangle(25, 24, 98, 80);
			//var highlightBg:Scale9Image = new Scale9Image(new Scale9Textures(MangoAssetManager.I.getTexture("sorted_bg"), new Rectangle(25, 24, 98, 80)));
			img.width = width;
			img.height = height;
			return img;
		}
	}
}