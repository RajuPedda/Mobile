package utils
{
	import com.mangogames.managers.MangoAssetManager;
	
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Check;
	import feathers.controls.Label;
	import feathers.controls.TabBar;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleButton;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.themes.MetalWorksMobileTheme;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;
	import starling.utils.Color;

	/**
	 * 
	 * @author Raju M.
	 * 
	 */	
	public class Ace2JakTheme extends MetalWorksMobileTheme
	{
		
		public function Ace2JakTheme(scaleToDPI:Boolean=true)
		{
			super();
		}
		
		[Embed(source="../assets/fonts/Vanilla Galaxies by Breely.ttf", embedAsCFF="false", fontFamily="bitmap")]
		private static const BitampFontVanilla:Class;
		
		override protected function initializeStyleProviders():void
		{
			super.initializeStyleProviders();
			getStyleProviderForClass( TextInput ).setFunctionForStyleName( "username-text-input", setCustomTextInputStyles );
			getStyleProviderForClass(Check).setFunctionForStyleName("custom-check", setCustomCheckStyles);
			getStyleProviderForClass( Label ).setFunctionForStyleName( "roomList-label", setCustomLabelStyles );
			getStyleProviderForClass( Label ).setFunctionForStyleName( "settings-label", setSettingsLabelStyles );
			getStyleProviderForClass( ToggleButton).setFunctionForStyleName( "custom-tab", setCustomTabStyles );
			
		}
		
		private function setCustomTabStyles(tabBar:TabBar):void
		{
			var whiteQuad:Quad	= new Quad(150, 35);
			
			tabBar.tabFactory = function():ToggleButton
			{
				var tab:ToggleButton = new ToggleButton();
				//tab.defaultSkin = whiteQuad; //new Image( texture );
				//tab.downSkin = whiteQuad;//new Image( texture );
				tab.defaultLabelProperties.textFormat = new TextFormat("Arial", 24, 0x323232, true );
				return tab;
			};
		}
		
		private function setCustomCheckStyles(check:Check):void
		{
			var texture:Texture = MangoAssetManager.I.getTexture("checkbox_green");
			var img:Image	= new Image(texture);
			img.scale9Grid	= new Rectangle(5, 5, 22, 22);
			check.defaultSkin = img;
		}
		
		private function setCustomTextInputStyles(txiInput:TextInput):void
		{
			var texture:Texture = MangoAssetManager.I.getTexture("type_box");
			var img:Image	= new Image(texture);
			img.scale9Grid	= new Rectangle(5, 5, 22, 22);
			txiInput.backgroundSkin = img;
			
			txiInput.textEditorFactory = function():ITextEditor
			{
				var editor:StageTextTextEditor = new StageTextTextEditor();
				editor.styleProvider = null;
				editor.fontFamily = "Arial"; //FontUtils.FONTFAMILY_ARIAL_ROUNDED;
				editor.fontSize = 25;// FontUtils.FONTSIZE_LARGE;
				editor.color = Color.BLACK;
				editor.textAlign = TextFormatAlign.CENTER;
				return editor;
			}
			txiInput.promptFactory = function():ITextRenderer
			{
				return new TextFieldTextRenderer();
			};
			
			txiInput.promptProperties.textFormat = new TextFormat( "Source Sans Pro", 23, 0x233312, true );
				
		}
		
		// room-list label
		private function setCustomLabelStyles(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 16;
				textRenderer.textFormat = new TextFormat( "Arial", fontSize, 0x0 );
				return textRenderer;
			}
		}
		
		private function setSettingsLabelStyles(label:Label):void
		{
			label.textRendererFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 16;
				textRenderer.textFormat = new TextFormat( "Arial", fontSize, 0xFFFFFF );
				return textRenderer;
			}
		}
		
	}
}