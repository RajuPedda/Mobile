package com.mangogames.views.login.signUp
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.views.AbstractBaseView;
	
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
	public class ChangePassword extends Sprite
	{
		private var PADDING:int	= 30;
		
		private var _currentPassword:TextInput;
		private var _passwordTI:TextInput;
		private var _confirmPassword:TextInput;
		private var _submitBtn:Button;
		private var _closeBtn:Button;
		
		private var container:Sprite;
		private var signUpPanelBg:Image;
		
		private var _changePassCallback:Function;
		
		public function ChangePassword(callback:Function)
		{
			super();
			_changePassCallback	= callback;
			init();
		}
		
		private function init():void
		{
			
			var obj:Object	= AbstractBaseView.getStageSize();
			var stageW:int	= obj.stageWidth;
			var stageH:int	= obj.stageHeight;
			
			container		= new Sprite();
			addChild(container);
			
			signUpPanelBg			= MangoAssetManager.I.getImage("signup_bg");
			ScaleUtils.applyPercentageScale(signUpPanelBg, 75, 65);
			container.addChild(signUpPanelBg);
			
			_currentPassword				= ControlUtils.createTextInput();
			_currentPassword.displayAsPassword	= true;
			_currentPassword.prompt		= " Current password";
			ScaleUtils.applyPercentageScale(_currentPassword, 40, 10);
			container.addChild(_currentPassword);
			_currentPassword.styleNameList.add( "username-text-input" );
			_currentPassword.validate();
			_currentPassword.x			= (signUpPanelBg.width-_currentPassword.width)/2;
			_currentPassword.y			= signUpPanelBg.y+ _currentPassword.height/2;
			
			_passwordTI				= ControlUtils.createTextInput();
			ScaleUtils.applyPercentageScale(_passwordTI, 40, 10);
			_passwordTI.displayAsPassword	= true;
			_passwordTI.prompt		= " New password";
			container.addChild(_passwordTI);
			_passwordTI.styleNameList.add( "username-text-input" );
			_passwordTI.validate();
			_passwordTI.x			= _currentPassword.x;
			_passwordTI.y			= _currentPassword.y+_currentPassword.height+_currentPassword.height/2;
			
			_confirmPassword				= ControlUtils.createTextInput();
			_confirmPassword.prompt		= " Confirm password";
			_confirmPassword.displayAsPassword	= true;
			ScaleUtils.applyPercentageScale(_confirmPassword, 40, 10);
			container.addChild(_confirmPassword);
			_confirmPassword.styleNameList.add( "username-text-input" );
			_confirmPassword.validate();
			_confirmPassword.x			= _currentPassword.x;
			_confirmPassword.y			= _passwordTI.y+_passwordTI.height+_passwordTI.height/2;
			
			_submitBtn 				= ControlUtils.createButton("submit_btn", "");
			ScaleUtils.applyPercentageScale(_submitBtn, 12, 10);
			container.addChild(_submitBtn);
			_submitBtn.x 			= (signUpPanelBg.width - _submitBtn.width)/2
			_submitBtn.y 			= signUpPanelBg.height - _submitBtn.height*1.2;
			_submitBtn.addEventListener(Event.TRIGGERED, onSubmit);
			
			_closeBtn 				= ControlUtils.createButton("submit_btn", "");
			ScaleUtils.applyPercentageScale(_closeBtn, 12, 10);
			container.addChild(_submitBtn);
			_closeBtn.x 			= (signUpPanelBg.width - _submitBtn.width)/2
			_closeBtn.y 			= signUpPanelBg.height - _submitBtn.height*1.2;
			_closeBtn.addEventListener(Event.TRIGGERED, onClose);
		}
		
		private function onSubmit():void
		{
			_changePassCallback.call();
		}
		
		private function onClose():void
		{
		}
	}
}