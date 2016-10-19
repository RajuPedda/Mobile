package com.mangogames.views.popup
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.views.game.tableview.TableView;
	
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	
	import utils.Fonts;
	
	public class AutoDropPopup extends Sprite
	{
		private var _table:TableView;

		public function AutoDropPopup(table:TableView)
		{
			super();
			_table = table;
			
			var quad:Quad = new Quad(Constants.TARGET_WIDTH, Constants.TARGET_HEIGHT, 0xffffff);
			quad.alpha = 0;
			addChild(quad);
			
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, Fonts.getInstance().mediumFont, Color.WHITE);
			var label:TextField = new TextField(1, 1, "Your hand will be dropped on your turn", tf);
			label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			label.x = quad.width / 2 - label.width / 2;
			label.y = quad.height / 2 - label.height / 2;
			trace("width ", label.width);
			addChild(label);
			
			var gameScreen:XML = MangoAssetManager.I.gameElements;

			var button:Button = new Button( MangoAssetManager.I.getTexture("auto_drop_btn"));
			button.textFormat.font = Fonts.getInstance().fontBold;
			button.textFormat.bold = true;
			button.textFormat.color = Fonts.getInstance().colorWhite;
			button.textFormat.size = Fonts.getInstance().mediumFont;
			button.x = _table.WIDTH -340;
			button.y = _table.HEIGHT -110;
			addChild(button);
			button.addEventListener(Event.TRIGGERED, onAutoDrop);
		}
		
		private function onAutoDrop(event:Event):void
		{
			_table.isAutoDrop = false;
			PopUpManager.removePopUp(this, true);
		}
	}
}