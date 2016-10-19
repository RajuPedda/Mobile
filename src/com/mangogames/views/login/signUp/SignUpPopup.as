package com.mangogames.views.login.signUp
{
	import com.mangogames.managers.MangoAssetManager;
	
	import feathers.controls.TextInput;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import utils.ControlUtils;
	import utils.ScaleUtils;
	
	/**
	 * 
	 * @author Raju Pedda.M
	 * 
	 */	
	public class SignUpPopup extends Sprite
	{
		private var PADDING:int	= 30;
		
		private var _usernameTI:TextInput;
		private var _passwordTI:TextInput;
		private var _mobileNoTI:TextInput;
		private var _enterOtpTI:TextInput;
		private var _submitBtn:Button;
		
		private var signUpPanelBg:Image;
		
		private var container:Sprite;
		private var _stageW:int;
		private var _stageH:int;
		private var _callback:Function;
		
		public function SignUpPopup(stageW:int, stageH:int)
		{
			super();
			_stageW	= stageW;
			_stageH	= stageH;
			init();
		}
		
		private function init():void
		{
			
			container		= new Sprite();
			addChild(container);
			
			signUpPanelBg			= MangoAssetManager.I.getImage("signup_bg");
			ScaleUtils.applyPercentageScale(signUpPanelBg, 70, 50);
			container.addChild(signUpPanelBg);
			
			_usernameTI				= ControlUtils.createTextInput();
			_usernameTI.prompt		= "User Name";
			ScaleUtils.applyPercentageScale(_usernameTI, 40, 10);
			container.addChild(_usernameTI);
			_usernameTI.styleNameList.add( "username-text-input" );
			_usernameTI.validate();
			_usernameTI.x			= (signUpPanelBg.width-_usernameTI.width)/2;
			_usernameTI.y			= signUpPanelBg.y+ _usernameTI.height/2;
			
			_passwordTI				= ControlUtils.createTextInput();
			ScaleUtils.applyPercentageScale(_passwordTI, 40, 10);
			_passwordTI.displayAsPassword	= true;
			_passwordTI.prompt		= "Password";
			container.addChild(_passwordTI);
			_passwordTI.styleNameList.add( "username-text-input" );
			_passwordTI.validate();
			_passwordTI.x			= _usernameTI.x;
			_passwordTI.y			= _usernameTI.y+_usernameTI.height+_usernameTI.height/2;
			
			_mobileNoTI				= ControlUtils.createTextInput();
			_mobileNoTI.prompt		= "Mobile No.";
			_mobileNoTI.restrict	= "0-9";
			ScaleUtils.applyPercentageScale(_mobileNoTI, 40, 10);
			container.addChild(_mobileNoTI);
			_mobileNoTI.styleNameList.add( "username-text-input" );
			_mobileNoTI.validate();
			_mobileNoTI.x			= _usernameTI.x;
			_mobileNoTI.y			= _passwordTI.y+_passwordTI.height+_passwordTI.height/2;
			
			container.x	= (_stageW - container.width)/2;
			container.y	= (_stageH - container.height)/2;
		}
		
		public function showEnterPasswordBox(callback:Function):void
		{
			_callback	= callback;
			container.removeChildren();
			
			signUpPanelBg			= MangoAssetManager.I.getImage("signup_bg");
			ScaleUtils.applyPercentageScale(signUpPanelBg, 70, 50);
			container.addChild(signUpPanelBg);
			
			_enterOtpTI				= ControlUtils.createTextInput();
			_enterOtpTI.prompt		= "Enter OTP";
			ScaleUtils.applyPercentageScale(_enterOtpTI, 40, 10);
			container.addChild(_enterOtpTI);
			_enterOtpTI.styleNameList.add( "username-text-input" );
			_enterOtpTI.validate();
			_enterOtpTI.restrict	= "0-9";
			_enterOtpTI.x			= (signUpPanelBg.width - _enterOtpTI.width)/2// <<1
			_enterOtpTI.y			= (signUpPanelBg.height-_enterOtpTI.height)/3;
			
			
			_submitBtn 				= ControlUtils.createButton("submit_btn", "");
			ScaleUtils.applyPercentageScale(_submitBtn, 12, 10);
			container.addChild(_submitBtn);
			_submitBtn.x 			= (signUpPanelBg.width - _submitBtn.width)/2
			_submitBtn.y 			= _enterOtpTI.y+_submitBtn.height*2;
			_submitBtn.addEventListener(Event.TRIGGERED, onSubmit);
			
			container.x	= (_stageW - container.width)/2;
			container.y	= (_stageH - container.height)/2;
		}
		
		private function onSubmit():void
		{
			_callback.call();
		}
		
		public function isAllValuesEnteredInTheRequiredFields():Boolean
		{
			var isAllDone:Boolean	= true;
			
			return 	isAllDone;
		}
	}
}