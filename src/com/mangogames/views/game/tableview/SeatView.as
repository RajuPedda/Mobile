package com.mangogames.views.game.tableview
{
	import com.mangogames.audio.SoundDirector;
	import com.mangogames.events.HandCardIndicatorTouchedEvent;
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.models.UserInfo;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.SeatImpl;
	import com.mangogames.services.SFSInterface;
	import com.mangogames.signals.ProxySignals;
	import com.mangogames.views.AbstractBaseView;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.DropShadowFilter;
	import starling.filters.GlowFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.Color;
	import starling.utils.HAlign;
	
	import utils.DrawShapeUtil;
	import utils.Fonts;
	import utils.ProfilePic;
	import utils.ScaleUtils;
	
	public class SeatView extends Sprite
	{
		public function SeatView(seatPos:int)
		{
			super();
			_seatPos = seatPos;
			_playIndicatingSound = false;
			
			var obj:Object	= AbstractBaseView.getStageSize();
			WIDTH			= obj.stageWidth;
			HEIGHT			= obj.stageHeight;
			
			_gameScreen 	= MangoAssetManager.I.gameElements;
			_seatsPos		= _gameScreen.theme.seats.seat;
		}
		
		private const NAME_ANCHOR:int = 58;
		
		private var _seatImpl:SeatImpl;
		private var _countDownTimer:Timer;
		private var _duration:int;
		private var _timerBg:Image;
		private var _turnTimeLabel:TextField;
		private var _playerName:TextField;
		private var _isGone:Boolean;
		private var _profilePic:ProfilePic;
		public var _txtWallet:TextField;
		private var _handCardIndicator:MovieClip;
		private var _seatPos:int;
		
		private var _playingHeartbeat:Boolean;
		private var _playIndicatingSound:Boolean;
		private var _seatsPos:XMLList;
		
		private var _gameScreen:XML;
		
		private var _randomiserCardPosX:int;
		private var _randomiserCardPosY:int;
		private var _isTurnAlertSoundPlaying:Boolean;
		private var _playerNameBg:Image;
		
		private var WIDTH:int;
		private var HEIGHT:int;
		
		override public function dispose():void
		{
			cleanup();
			super.dispose();
		}
		
		private function cleanup():void
		{
			if (_seatImpl && _seatImpl.player && _seatImpl.player.id == SFSInterface.getInstance().userInfo.id)
			{
				removeChild(_profilePic);
				_profilePic = null;
			}
			
			if (_countDownTimer)
				onTimerComplete(null);
			
			removeChildren(0, -1, true);
			_handCardIndicator.visible = false;
			_seatImpl = null;
		}
		
		public function initHandCards(handCardContainer:Sprite):void
		{
			//var gameScreen:XML = MangoAssetManager.I.gameElements;
			
			if (_seatPos == 0)
			{
				_handCardIndicator ||= new MovieClip(MangoAssetManager.I.getTextures("Back"), 1);
				_handCardIndicator.scaleX = 0.9;
				_handCardIndicator.scaleY = 0.9;
			}
			else
				_handCardIndicator ||= new MovieClip(MangoAssetManager.I.getTextures("cardsback"), 6); 
			
			_handCardIndicator.fps = 30;
			_handCardIndicator.pivotX = _handCardIndicator.width / 2;
			_handCardIndicator.pivotY = _handCardIndicator.height / 2;
			var dropShadow:DropShadowFilter	= new DropShadowFilter();
			_handCardIndicator.filter = dropShadow; //BlurFilter.createDropShadow();
			
			// rotate cards according to seat position
			var rotation:int = _seatsPos[_seatPos].handCards.@rotation;
			_handCardIndicator.rotation = rotation * (Math.PI / 180);
			handCardContainer.addChild(_handCardIndicator);
			_handCardIndicator.visible = false;
			
			_handCardIndicator.x = _seatsPos[_seatPos].handCards.@x;
			_handCardIndicator.y = _seatsPos[_seatPos].handCards.@y;
			
			//if (_seatPos == 0) // my seat
			{
				_handCardIndicator.addEventListener(TouchEvent.TOUCH, function (event:TouchEvent):void
				{
					var touch:Touch = event.getTouch(_handCardIndicator);
					if (touch && touch.phase == TouchPhase.ENDED)
						dispatchEvent(new HandCardIndicatorTouchedEvent());
				});
			}
		}
		
		public function initHandCardsWhenSpectatorIsThere(handCardContainer:Sprite):void
		{
			_handCardIndicator = new MovieClip(MangoAssetManager.I.getTextures("cardsBack"), 6); 
			_handCardIndicator.fps = 30;
			_handCardIndicator.pivotX = _handCardIndicator.width / 2;
			_handCardIndicator.pivotY = _handCardIndicator.height / 2;
			var dropShadow:DropShadowFilter	= new DropShadowFilter();
			_handCardIndicator.filter = dropShadow; //BlurFilter.createDropShadow();
			
			// rotate cards according to seat position
			var rotation:int = _seatsPos[_seatPos].handCards.@rotation;
			_handCardIndicator.rotation = rotation * (Math.PI / 180);
			handCardContainer.addChild(_handCardIndicator);
			_handCardIndicator.visible = false;
			
			_handCardIndicator.x = _seatsPos[_seatPos].handCards.@x;
			_handCardIndicator.y = _seatsPos[_seatPos].handCards.@y;
			_handCardIndicator.y += 40;
		}
		
		public function initEmptySeat():void
		{
			_emptySeat = new Button(MangoAssetManager.I.getTexture("invite_btn"), "");
			_emptySeat.x = 0;
			_emptySeat.y = 0;
			ScaleUtils.applyPercentageScale(_emptySeat, 7, 11);
			addChild(_emptySeat);
			_emptySeat.addEventListener(Event.TRIGGERED, function(event:Event):void
			{
				
			});
			
			reposition(_seatPos, -1);
		}
		
		public function reposition(seatPos:int, previousPosition:int):void
		{
			_seatPos = seatPos;
			
			var gameScreen:XML = MangoAssetManager.I.gameElements;
			var posX:int = gameScreen.theme.seats.seat[seatPos].@x;
			var posY:int = gameScreen.theme.seats.seat[seatPos].@y;
			
			// TO-DO - when user rejoin, need to check the position in all mobiles
			if (previousPosition != -1)
			{
				
				x = gameScreen.theme.seats.seat[previousPosition].@x;
				y = gameScreen.theme.seats.seat[previousPosition].@y;
				
				var tween:Tween = new Tween(this, 1, Transitions.EASE_IN_OUT);
				
				tween.moveTo(posX - width / 2, posY - height / 2);
				Starling.juggler.add(tween);
			}
			else
			{
				// layout
				switch(_seatPos)
				{
					case 0:	
						x = -_emptySeat.width ;
						y =	(HEIGHT-_emptySeat.height)/2;
						break;
					case 1:	
						x = WIDTH-_emptySeat.width*2;
						y =		_emptySeat.height+_emptySeat.height/1.5;
						break;
					case 2:	
						x =  WIDTH-_emptySeat.width*5+5;
						y =		_emptySeat.height+_emptySeat.height/2 - 15;
						break;
					case 3:
						x = (WIDTH - _emptySeat.width)/2;
						y =	_emptySeat.height+_emptySeat.height/2-20;
						break;
					case 4:	
						x = WIDTH/2 - (_emptySeat.width*3+10);
						y =		_emptySeat.height+_emptySeat.height/2-15;
						break;
					case 5:	
						x = _emptySeat.width;
						y =	_emptySeat.height+_emptySeat.height/1.5;
						break;
				}
			}
		}
		
		public function seatPlayer(seatImpl:SeatImpl, showWallet:Boolean, previousPosition:int = -1, player:PlayerImpl=null):void
		{
			if (!seatImpl)
				throw new Error("Why is the seat impl empty!?");
			
			_seatImpl = seatImpl;
			
			if (_seatImpl.player)
			{
				cleanup();
				_seatImpl = seatImpl;
				var userInfo:UserInfo	= SFSInterface.getInstance().userInfo;
				var avatarURL:String;
				
				if(userInfo.id == _seatImpl.player.id)
				{
					if(userInfo.avatarId == "")
						SFSInterface.getInstance().userInfo.avatarId	= player.iconurl;
					avatarURL	= SFSInterface.getInstance().userInfo.avatarId;
				}
				else
				{
					avatarURL	= player.iconurl;
				}
				
				
				initAvatar(avatarURL);
				toggleHideWallet(showWallet);
			}
			
			reposition(_seatPos, _seatImpl.player ? previousPosition : -1);
		}
		
		private var _myAvatarContainer:Sprite;
		private var _opponentAvatarContainer:Sprite;
		private var _emptySeat:Button;
		private var _dealerSymbol:Image;
		
		public function initAvatar(updatedURL:String=null):void
		{
			if(_profilePic)
				_profilePic.dispose();
			
			_profilePic	= new ProfilePic(updatedURL);//new ProfilePic(_seatImpl.player.iconurl);
			_profilePic.width = 61;
			_profilePic.height = 61;
			_profilePic.x = 0;
			_profilePic.y = 0;
			
			var nameStr:String = _seatImpl.player.name && _seatImpl.player.name.length > 0 ?
				_seatImpl.player.name : "n/a";
			
			_playerNameBg	= new Image(MangoAssetManager.I.getTexture("player_id_bg"));
			_playerNameBg.x	= 0;
			
			_playerName = new TextField(1, 1, nameStr);
			_playerName.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_playerName.format.size = 12;//Fonts.getInstance().smallFont;
			_playerName.format.color = Fonts.getInstance().colorWhite;
			_playerName.touchable = false;
			if (_playerName.text.length > 7)
				_playerName.text = _playerName.text.slice(0, 8);
			
			// wallet
			_txtWallet = new TextField(1, 1, nameStr);
			_txtWallet.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtWallet.format.size = 12;//Fonts.getInstance().smallFont;
			_txtWallet.format.color = Fonts.getInstance().colorGold;
			_txtWallet.touchable = false;
			
			if(seatPos ==0)
			{
				_profilePic.x	= 0;
				_profilePic.y	= 2;
				_myAvatarContainer	= new Sprite();
				var box:Sprite = DrawShapeUtil.getBoxWithBorderWithSprite(100, 90, 0x2b2b2b, 0xffffff, 1);
				_profilePic.width	= box.width;
				_profilePic.height	= box.height-4;
				
				addChild(_myAvatarContainer);
				_myAvatarContainer.addChildAt(box,0);
				_myAvatarContainer.addChild(_profilePic);
				_myAvatarContainer.addChild(_playerNameBg);
				_myAvatarContainer.addChild(_playerName);
				_myAvatarContainer.addChild(_txtWallet);
				// to show intially on the screen
				_myAvatarContainer.x	= _myAvatarContainer.x + _myAvatarContainer.width;			
				_myAvatarContainer.addEventListener(TouchEvent.TOUCH, onMyAvatarClickHandler);
			}
			
			_playerNameBg.x	= (_profilePic.width - _playerNameBg.width)/2;
			_playerNameBg.y	= _profilePic.height;
			
			_playerName.x = _playerNameBg.x +20;
			_playerName.y = _playerNameBg.y + 1;
			
			_txtWallet.x = _playerNameBg.x + 20;
			_txtWallet.y = _playerNameBg.y + 15;
			
			if(seatPos>0)
			{
				_opponentAvatarContainer	= new Sprite();
				addChild(_opponentAvatarContainer);
				_opponentAvatarContainer.addChild(_profilePic);
				_opponentAvatarContainer.addChild(_playerNameBg);
				_opponentAvatarContainer.addChild(_playerName);
				_opponentAvatarContainer.addChild(_txtWallet);
			}
			
			updateWallet(_seatImpl.player.wallet);
			
			if(seatPos ==0)
			{
				_randomiserCardPosX =  this.x + _profilePic.width; 
				_randomiserCardPosY =  this.y + _profilePic.height/2; 
			}
			else
			{
				_randomiserCardPosX =  this.x + _profilePic.width/2; 
				_randomiserCardPosY =  this.y + _profilePic.height/2; 
			}
		}
		
		public function updateProfilePic():void
		{
			//_myAvatarContainer.x	= 10 ;
			_myAvatarContainer.x	= _myAvatarContainer.x >_myAvatarContainer.width/2 ? 10:_myAvatarContainer.x + _myAvatarContainer.width/2;
		}
		
		// turn timer UI
		private function turnTimerUI():void
		{
			// text bg
			_timerBg = new Image(MangoAssetManager.I.getTexture("player_timer_bg"));
			
			// timer text
			_turnTimeLabel = new TextField(50, 20, (20).toString()); //(duration -15).toString()
			_turnTimeLabel.format.size = Fonts.getInstance().smallFont;
			_turnTimeLabel.format.color = Fonts.getInstance().colorWhite;
			_turnTimeLabel.format.horizontalAlign	= HAlign.CENTER;
			_turnTimeLabel.touchable = false;
			_turnTimeLabel.visible	= false;
			_timerBg.visible		= false;
			
			_seatPos==0?_myAvatarContainer.addChild(_timerBg):addChild(_timerBg);
			_seatPos==0?_myAvatarContainer.addChild(_turnTimeLabel):addChild(_turnTimeLabel);
			
			_timerBg.x = _profilePic.width -(_timerBg.width)/2;
			_timerBg.y = (_profilePic.height -_timerBg.height)/2;
			
			_turnTimeLabel.x = _timerBg.x + (_timerBg.width - _turnTimeLabel.width) / 2;
			_turnTimeLabel.y = _timerBg.y + (_timerBg.height - _turnTimeLabel.height) / 2;
		}
		
		public function setDealerPos():void
		{
			_dealerSymbol 			= new Image(MangoAssetManager.I.getTexture("dealerSymbol1"));
			_dealerSymbol.x 		= _seatPos==0?_profilePic.width - _dealerSymbol.width/2: -_dealerSymbol.width/2;
			_dealerSymbol.y 		= -_dealerSymbol.height/2;
			_seatPos==0?_myAvatarContainer.addChild(_dealerSymbol):addChild(_dealerSymbol);
		}
		
		public function removeLastDealerSymbol():void
		{
			if(_dealerSymbol)
			{
				_dealerSymbol.removeFromParent(true);
			}
		}
		
		public function getDealerPos(dealerSymbol:Image):Point
		{
			var point:Point	= new Point();
			point.x		= _profilePic.x + _profilePic.width - dealerSymbol.width/2;
			point.y		= _profilePic.y+ dealerSymbol.height/2 * -1;
			return point;
		}
		
		private function onMyAvatarClickHandler(event:TouchEvent):void
		{
			var sprite:Sprite	= event.currentTarget as Sprite;
			var touch:Touch = event.getTouch(sprite);
			if (touch && touch.phase == TouchPhase.ENDED)
			{
				var tween:Tween = new Tween(sprite, 0.2, Transitions.EASE_OUT);
				var xPos:int	= sprite.x >sprite.width/2 ? 10:sprite.x + sprite.width/2;
				tween.moveTo(xPos, sprite.y);
				Starling.juggler.add(tween);
			}
			
		}
		
		private function updateAvatar():void
		{
			
		}
		
		private function placeNameAndWallet():void
		{
			// name
			var nameStr:String = _seatImpl.player.name && _seatImpl.player.name.length > 0 ?
				_seatImpl.player.name : "n/a";
			
			_playerNameBg	= new Image(MangoAssetManager.I.getTexture("player_id_bg"));
			_playerNameBg.x	= -60;
			
			if(seatPos ==0)
			{
				_playerNameBg.y	= 50;
			}
			else if(seatPos == 1)
			{
				_playerNameBg.x = -60;
				_playerNameBg.y	= 50;
			}
			else if(seatPos == 5)
			{
				_playerNameBg.x = 10;
				_playerNameBg.y	= -40;
			}
			else
			{
				_playerNameBg.y	= 10;
			}
			
			addChild(_playerNameBg);
			
			_playerName = new TextField(1, 1, nameStr);
			_playerName.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_playerName.format.size = Fonts.getInstance().smallFont;
			_playerName.format.color = Fonts.getInstance().colorWhite;
			_playerName.touchable = false;
			if (_playerName.text.length > 7)
				_playerName.text = _playerName.text.slice(0, 8);
			
			addChild(_playerName);
			_playerName.x = _playerNameBg.x + 20;
			_playerName.y = _playerNameBg.y + 3;
			
			// wallet
			_txtWallet = new TextField(1, 1, nameStr);
			_txtWallet.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_txtWallet.format.size = Fonts.getInstance().smallFont;
			_txtWallet.format.color = Fonts.getInstance().colorGold;
			_txtWallet.touchable = false;
			addChild(_txtWallet);
			_txtWallet.x = _playerNameBg.x + 25;
			_txtWallet.y = _playerNameBg.y + 25;
			updateWallet(_seatImpl.player.wallet);
		}
			
		
		private function onTimerTick(event:TimerEvent):void
		{
			_turnTimeLabel.visible	= true;
			_timerBg.visible		= true;
			
			var progress:int = _duration - _countDownTimer.currentCount;
			if(progress ==0)
				SoundDirector.getInstance().stopSound(SoundDirector.DINGDONG);
			
			if(progress == 15)
			{
				_playIndicatingSound	= true;
				_turnTimeLabel.visible	= false;
				_timerBg.visible		= false;
			}
			
			if (_seatPos == 0 && _playIndicatingSound && !_isTurnAlertSoundPlaying)
			{
				_isTurnAlertSoundPlaying	= true;
				SoundDirector.getInstance().playSound(SoundDirector.DINGDONG, 0.1, 10); // DINGDONG
			}
			
			if(progress == 1 && TableView(this.parent).isShowProcessed && _playIndicatingSound)
			{
				TableView(this.parent).removeConfirmationPopup();
			}
			var value:int	= Math.abs(progress);
			
			if(!_playIndicatingSound && progress >=15)
			{
				_turnTimeLabel.text = (Math.abs(progress -15)).toString();
			}
			else
			{
				if(progress<10)
					_turnTimeLabel.format.horizontalAlign	= HAlign.CENTER;
				
				_turnTimeLabel.text = (Math.abs(progress)).toString();
			}
		}
		
		private function onFirstTimerComplete(event:TimerEvent):void
		{
			_playIndicatingSound = true;
			_turnTimeLabel.visible	= false;
			
		/*	_countDownTimer.reset();
			_duration = 10;
			_countDownTimer.repeatCount = 10;
			_countDownTimer.start();
			_countDownTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onFirstTimerComplete);
			_countDownTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);*/
		}
		
		private function onTimerComplete(event:TimerEvent):void
		{
			_playIndicatingSound = false;
			if (_countDownTimer)
			{
				_countDownTimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
				_countDownTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				_countDownTimer.stop();
				_countDownTimer = null;
			}
			
			if(_turnTimeLabel) _turnTimeLabel.removeFromParent(true);
		
			if(_timerBg) _timerBg.removeFromParent(true);
			
			if (_playingHeartbeat)
				SoundDirector.getInstance().stopSound(SoundDirector.HEARTBEAT);
			_playingHeartbeat = false;
		}
		
		public function simulateTransition(from:int, to:int):void
		{
			//var gameScreen:XML = MangoAssetManager.I.gameElements;
			
			var fromX:int = _seatsPos[from].@x;
			var fromY:int = _seatsPos[from].@y;
			
			var toX:int = _seatsPos[to].@x;
			var toY:int = _seatsPos[to].@y;
			
			x = fromX - width / 2;
			y = fromY - height / 2;
			
			var tween:Tween = new Tween(this, 0.6);
			tween.moveTo(toX - width / 2, toY - height / 2);
			Starling.juggler.add(tween);
		}
		
		public function makeEmpty():void
		{
			cleanup();
			initEmptySeat();
		}
		
		public function addTurnTimer(duration:int):void
		{
			removeTurnTimer();
			_isTurnAlertSoundPlaying	= false;
			_duration = duration;
			duration = duration;
			var glowFilter:GlowFilter	= new GlowFilter(Color.WHITE, 1, 10);
			_handCardIndicator.filter = glowFilter; 
			
			_countDownTimer = new Timer(1000, duration);
			_countDownTimer.start();
			_countDownTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
			_countDownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);	
			
			turnTimerUI();
			
			_playingHeartbeat = false;
		}
		
		public function removeTurnTimer():void
		{
			if(_handCardIndicator.filter != null)
			{
				_handCardIndicator.filter.dispose();
				_handCardIndicator.filter = null;
			}
			SoundDirector.getInstance().stopSound(SoundDirector.DINGDONG);
			onTimerComplete(null);
		}
		
		public function toggleShowHandCards(value:Boolean):void
		{
			_handCardIndicator.x = _seatsPos[_seatPos].handCards.@x;
			_handCardIndicator.y = _seatsPos[_seatPos].handCards.@y;
			
			_handCardIndicator.visible = value;
			if (value)
			{
				Starling.juggler.remove(_handCardIndicator); 
				_handCardIndicator.currentFrame = 0;
			}
		}
		
		public function updateWallet(amount:int):void
		{
			_seatImpl.player.wallet = amount;
			_txtWallet.text = Number(amount / 100).toFixed(2).toString();
			ProxySignals.getInstance().updateInplaySignal.dispatch();
		}
		
		public function updateScore(score:int, isRejoin:Boolean=false):void
		{
			// use wallet to show the score for pool games
			if(_txtWallet)
			{
				_txtWallet.visible = true;
				var lastValue:int	= Number(_txtWallet.text);
				_txtWallet.text = isRejoin? score.toString() : (score+ lastValue).toString();
			}
			
		}
		
		public function toggleHideWallet(value:Boolean):void
		{
			_txtWallet.visible = value;
		}
		
		public function addDropAnimtion():void
		{
			trace(_handCardIndicator.x);
			_handCardIndicator.x = _seatsPos[_seatPos].dropImgPos.@x;
			_handCardIndicator.y = _seatsPos[_seatPos].dropImgPos.@y;
			
			Starling.juggler.add(_handCardIndicator); 
			_handCardIndicator.loop = false;
		}
		
		public function get seatImpl():SeatImpl { return _seatImpl; }
		public function get isEmpty():Boolean { return !_seatImpl || !_seatImpl.player; }
		public function get isGone():Boolean { return _isGone; }
		public function set isGone(value:Boolean):void { _isGone = value; makeEmpty(); }
		public function get handCardPosX():int { return _handCardIndicator.x; }
		public function get handCardPosY():int { return _handCardIndicator.y; }
		public function get randomiserCardPosX():int { return  _randomiserCardPosX; }
		public function get randomiserCardPosY():int { return  _randomiserCardPosY; }
		public function get seatPos():int { return _seatPos; }
	}
}