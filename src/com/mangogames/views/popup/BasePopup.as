package com.mangogames.views.popup
{
	
	import com.mangogames.managers.MangoAssetManager;
	
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.Color;
	
	import utils.ControlUtils;
	import utils.ScaleType;
	import utils.ScaleUtils;
	
	public class BasePopup extends Sprite
	{
		public static const POPUPTYPE_SMALL:String = "popup_small";
		public static const POPUPTYPE_MEDIUM:String = "popup_medium";
		public static const POPUPTYPE_LARGE:String = "popup_large";
		public static const POPUPTYPE_CUSTOM:String = "popup_custom";
		public static const POPUPTYPE_NOBG:String = "popup_nobg";
		
		protected var _btnOk:Button;
		protected var _btnCancel:Button;
		protected var _btnClose:Button;
		
		private var _closeCallback:Function;
		private var _triggerClose:Boolean;
		
		public function BasePopup(popupType:String, okCallback:Function = null, cancelCallback:Function = null, closeCallback:Function = null, useDeafultScale:Boolean = true)
		{
			// base popup is a smart popup wich arranges itself according to the parameters provided
			super();
			
			if (popupType != POPUPTYPE_NOBG)
				addChild(getPopupBg(popupType));
			
			_triggerClose = false;
			
			// depending upon whatever values been provided, constuct buttons
			// each of the button will eventually close the popup
			if (okCallback)
			{
				_btnOk = ControlUtils.createButton("button_yes_green", "");
				addChild(_btnOk);
				_btnOk.addEventListener(Event.TRIGGERED, function (event:Event):void
				{
					okCallback();
					closePopup();
				});
			}
			
			if (cancelCallback)
			{
				_btnCancel = ControlUtils.createButton("button_no_red", "");
				addChild(_btnCancel);
				_btnCancel.addEventListener(Event.TRIGGERED, function (event:Event):void
				{
					cancelCallback();
					closePopup();
				});
			}
			
			_closeCallback = closeCallback;
			if (_closeCallback)
			{
				_btnClose = ControlUtils.createButton("button_close", "");
				addChild(_btnClose);
				_triggerClose = true;
				_btnClose.addEventListener(Event.TRIGGERED, function (event:Event):void
				{
					closePopup();
				});
			}
			
			arrangeButtons(popupType);
			initUI();
			
			if (useDeafultScale)
				ScaleUtils.applyScale(this, ScaleType.NO_BORDER);
			
			// HACK: to put the close button on top of everything
			if (_btnClose)
				addChildAt(_btnClose, numChildren - 1);
		}
		
		override public function dispose():void
		{
			if (_btnOk)
				_btnOk.dispose();
			
			if (_btnCancel)
				_btnCancel.dispose();
			
			if (_btnClose)
				_btnClose.dispose();
			
			super.dispose();
		}
		
		private function arrangeButtons(popupType:String):void
		{
			// first arrange the close button at top right
			if (_btnClose)
			{
				_btnClose.x = width - _btnClose.width - 5;
				_btnClose.y = 5;
			}
			
			// now according to the popup type, arrange ok and cancel button
			// if the popup type is small, then arrange the buttons on the sides
			if (popupType == POPUPTYPE_SMALL)
			{
				if (_btnOk)
				{
					_btnOk.x = width - _btnOk.width - 30;
					_btnOk.y = (height - _btnOk.height) / 2;
				}
				
				if (_btnCancel)
				{
					_btnCancel.x = 30;
					_btnCancel.y = (height - _btnCancel.height) / 2;
				}
			}
			else
			{
				if (_btnOk)
				{
					_btnOk.x = (width - _btnOk.width) / 2;
					_btnOk.y = height - _btnOk.height - 18;
				}
				
				if (_btnCancel)
				{
					_btnCancel.x = (width - _btnCancel.width) / 2;
					_btnCancel.y = height - _btnCancel.height - 18;
				}
				
				// if both buttons are present then arrange accordingly
				if (_btnOk && _btnCancel)
				{
					_btnCancel.x -= 100;
					_btnOk.x += 100;
				}
			}
		}
		
		protected function initUI():void
		{
			// to be overridden by client
		}
		
		public function closePopup():void
		{
			if (_closeCallback && _triggerClose)
				_closeCallback();
			
			if (PopUpManager.isPopUp(this))
				PopUpManager.removePopUp(this, true);
		}
		
		public static function getPopupBg(popupType:String):DisplayObject
		{
			/*var texBg:Scale9Textures = new Scale9Textures(MangoAssetManager.I.getTexture("popup"), new Rectangle(32, 32, 64, 64));
			var imgBg:Scale9Image = new Scale9Image(texBg);*/
			var imgBg:Image	= new Image(MangoAssetManager.I.getTexture("popup"));
			imgBg.scale9Grid	= new Rectangle(32, 32, 64, 64);
			switch (popupType)
			{
				case POPUPTYPE_SMALL:
					imgBg.width = 436;
					imgBg.height = 162;
					break;
				
				case POPUPTYPE_MEDIUM:
					imgBg.width = 676;
					imgBg.height = 402;
					break;
				
				case POPUPTYPE_LARGE:
					imgBg.width = 944;
					imgBg.height = 561;
					break;
				/*case POPUPTYPE_CUSTOM:
					return getCustomBankground();*/
				
				case POPUPTYPE_NOBG:
					imgBg.visible = false;
					break;
			}
			return imgBg;
		}
		
		private static function getCustomBankground():Shape
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(Color.RED);
			shape.graphics.drawRoundRect(0, 0, 600, 350, 10); // red border
			shape.graphics.endFill();
			shape.graphics.beginFill(Color.GRAY);
			shape.graphics.drawRoundRect(5, 5, 590, 340, 10); // gray panel
			shape.graphics.endFill();
			return shape;
		}
		
		public function get canAutoClose():Boolean { return true; }
	}
}