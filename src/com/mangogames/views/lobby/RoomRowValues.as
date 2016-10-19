package com.mangogames.views.lobby
{
	import com.mangogames.views.AbstractBaseView;
	
	import flash.text.TextFormat;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.ITextRenderer;
	
	import starling.display.Sprite;
	
	import utils.ScaleUtils;

	/**
	 * 
	 * @author Raju Pedda.M
	 * 
	 */	
	public class RoomRowValues extends Sprite
	{
		private var _gameType:String;
		private var _betAmount:int;
		private var _maxPlayer:int;
		private var _status:String;
		private var _playersCount:int;
		
		private var _gameTypeLabel:Label;
		private var _betAmountLabel:Label;
		private var _maxUsersLabel:Label;
		private var _statusLabel:Label;
		private var _playersCountLabel:Label;
		private var _btnJoin:Button;
		private var stageW:int;
		private var stageH:int;
		
		private var PADDING:int	= 20;
		
		public function RoomRowValues()
		{
			super();
			init();
		}
		
		private function init():void
		{
			var obj:Object		= AbstractBaseView.getStageSize();
			stageW				= obj.stageWidth;
			stageH				= obj.stageHeight;
			var posToScreen:int	= stageW/8;
			
			_gameTypeLabel		= new Label();
			_gameTypeLabel.x	=  PADDING*2;
			_gameTypeLabel.styleNameList.add("roomList-label");
			addChild(_gameTypeLabel);
			
			_betAmountLabel		= new Label();
			_betAmountLabel.x	=  _gameTypeLabel.x + posToScreen +PADDING*2;
			_betAmountLabel.styleNameList.add("roomList-label");
			addChild(_betAmountLabel);
			
			_maxUsersLabel		= new Label();
			_maxUsersLabel.x	=  _betAmountLabel.x +posToScreen
			_maxUsersLabel.styleNameList.add("roomList-label");
			addChild(_maxUsersLabel);
			
			_statusLabel		= new Label();
			_statusLabel.x		=  _maxUsersLabel.x+ posToScreen;
			_statusLabel.styleNameList.add("roomList-label");
			addChild(_statusLabel);
			
			_playersCountLabel	= new Label();
			_playersCountLabel.x=  _statusLabel.x + posToScreen+PADDING;
			_playersCountLabel.styleNameList.add("roomList-label");
			addChild(_playersCountLabel);
			
			_btnJoin			= new Button();
			ScaleUtils.applyPercentageScale(_btnJoin, 15, 7);
			_btnJoin.x			= _playersCountLabel.x + posToScreen+PADDING;
			_btnJoin.y			= _playersCountLabel.y - PADDING/2;
			
			_btnJoin.labelFactory = function():ITextRenderer
			{
				var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
				textRenderer.styleProvider = null;
				var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 18;
				textRenderer.textFormat = new TextFormat( "Arial", fontSize, 0x0 );
				//textRenderer.embedFonts = true;
				return textRenderer;
			}
				
			addChild(_btnJoin);
			
		}

		public function get gameTypeLabel():Label{return _gameTypeLabel;}
		public function set gameTypeLabel(value:Label):void{_gameTypeLabel = value;}
		public function get betAmountLabel():Label{return _betAmountLabel;}
		public function set betAmountLabel(value:Label):void{_betAmountLabel = value;}
		public function get maxUsersLabel():Label{return _maxUsersLabel;}
		public function set maxUsersLabel(value:Label):void{_maxUsersLabel = value;}
		public function get statusLabel():Label{return _statusLabel;}
		public function set statusLabel(value:Label):void{_statusLabel = value;}
		public function get playersCountLabel():Label{return _playersCountLabel;}
		public function set playersCountLabel(value:Label):void{_playersCountLabel = value;}
		public function get btnJoin():Button{return _btnJoin;}
		public function set btnJoin(value:Button):void{_btnJoin = value;}
		
	


	}
}