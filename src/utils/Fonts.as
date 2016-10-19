package utils
{
	import flash.net.URLLoader;

	public class Fonts
	{
		private var _headerFont:Number = 40;
		private var _largeFont:Number = 35;
		private var _mediamFont:Number = 30;
		private var _smallFont:Number = 20;
		
		private var _colorWhite:int = 0xFFFFFF;
		private var _colorBlack:int = 0x000000;
		private var _colorRed:int = 0xFF0000;
		private var _colorGreen:int = 0x0c9405;
		private var _colorGold:int = 0xFFFF00;
		private var _colorGray:int = 0x222222;
		private var _colorGraylite:int = 0x999999;
		private var _colorLightGold:int = 0xFFFF99;
		private var _colorBlue:int	= 0x003399;
		private var _colorDarkGold:int = 0x362A19;
		private var _fontRegular:String = "";
		private var _fontBold:String = "";
		private var _loader:URLLoader = new URLLoader();
		private static var _instance:Fonts;
		
		private var _font30:Number = 0;
		
		public static var DEFAULT_FONT:String = "ARIAL";
		
		
		
		public function Fonts(ic:InternalClass)
		{
			if(ic == null)
			{
				throw new Error("Cannot create instance of singleton class Fonts, use getInstance() instead");
			}
		}
		
		public function get colorGreen():int
		{
			return _colorGreen;
		}

		public function set colorGreen(value:int):void
		{
			_colorGreen = value;
		}

		public function get colorRed():int
		{
			return _colorRed;
		}

		public function set colorRed(value:int):void
		{
			_colorRed = value;
		}

		public function get colorGraylite():int
		{
			return _colorGraylite;
		}

		public function set colorGraylite(value:int):void
		{
			_colorGraylite = value;
		}

		public function get font30():Number
		{
			return _font30;
		}

		public function set font30(value:Number):void
		{
			_font30 = value;
		}

		public function get colorDarkGold():int
		{
			return _colorDarkGold;
		}

		public function set colorDarkGold(value:int):void
		{
			_colorDarkGold = value;
		}

		public function get fontRegular():String
		{
			return _fontRegular;
		}

		public function set fontRegular(value:String):void
		{
			_fontRegular = value;
		}

		public function get fontBold():String
		{
			return _fontBold;
		}

		public function set fontBold(value:String):void
		{
			_fontBold = value;
		}

		public function get colorLightGold():int
		{
			return _colorLightGold;
		}

		public function set colorLightGold(value:int):void
		{
			_colorLightGold = value;
		}

		public function get colorGold():int
		{
			return _colorGold;
		}

		public function set colorGold(value:int):void
		{
			_colorGold = value;
		}

		public function get colorBlack():int
		{
			return _colorBlack;
		}

		public function set colorBlack(value:int):void
		{
			_colorBlack = value;
		}

		public function get colorWhite():int
		{
			return _colorWhite;
		}

		public function set colorWhite(value:int):void
		{
			_colorWhite = value;
		}

		public static function getInstance():Fonts
		{
			if(_instance == null)
			{
				_instance = new Fonts(new InternalClass());
			}
			return _instance;
		}
		
		public function setFontXML(fontXML:XML):void
		{
			_headerFont = fontXML.headerfont.@size;
			_largeFont = fontXML.largefont.@size;
			_mediamFont = fontXML.mediumfont.@size;
			_smallFont = fontXML.smallfont.@size;
			_font30 = fontXML.font30.@size;
		}
		
		public function get headerFont():Number
		{
			return _headerFont;
		}
		
		public function set headerFont(value:Number):void
		{
			_headerFont = value;
		}

		public function get smallFont():Number
		{
			return _smallFont;
		}

		public function set smallFont(value:Number):void
		{
			_smallFont = value;
		}

		public function get mediumFont():Number
		{
			return _mediamFont;
		}

		public function set mediumFont(value:Number):void
		{
			_mediamFont = value;
		}

		public function get largeFont():Number
		{
			return _largeFont;
		}

		public function set largeFont(value:Number):void
		{
			_largeFont = value;
		}

		public function get colorGray():int
		{
			return _colorGray;
		}

		public function set colorGray(value:int):void
		{
			_colorGray = value;
		}

		public function get colorBlue():int
		{
			return _colorBlue;
		}

		public function set colorBlue(value:int):void
		{
			_colorBlue = value;
		}


		
	}
}
internal class InternalClass{}