package com.mangogames.views.game
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.rummy.model.impl.PlayerSettlementImpl;
	
	import feathers.controls.ScrollContainer;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Color;
	
	import utils.DrawShapeUtil;
	import utils.Fonts;
	import utils.PlayerState;
	
	public class HistoryPopup extends Sprite
	{
		private var _container:ScrollContainer;
		private var _lblNetAmount:TextField;

		public function HistoryPopup()
		{
			super();
			
			initScreen();	
		}
		
		override public function dispose():void
		{
			cleanup();
			
			super.dispose();
		}
		
		private function initScreen():void
		{
			var bg:Image = new Image(MangoAssetManager.I.getTexture("history_popup"));
			addChild(bg);
			
			var btnClose:Button = new Button(MangoAssetManager.I.getTexture("close_btn"));
			addChild(btnClose);
			btnClose.x = bg.width - btnClose.width - 5;
			btnClose.y = 3;
			btnClose.addEventListener(Event.TRIGGERED, onClickClose);
			
			_container = new ScrollContainer();
			addChild(_container);
			_container.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
			_container.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_ON;
			_container.x = 8;
			_container.y = 60;
			_container.width = bg.width-20;
			_container.height = bg.height - 105;
			
			var lblHeader:TextField = createLabel("History")
			lblHeader.x = 130;
			lblHeader.y = 12;
			lblHeader.format.bold	= true;
			addChild(lblHeader);
			
			var lblNet:TextField = createLabel("Net :- ")
			lblNet.x = 290;
			lblNet.y = 12;
			addChild(lblNet);
			
			_lblNetAmount = createLabel("0");
			_lblNetAmount.x = 330;
			_lblNetAmount.y = 12;
			_lblNetAmount.format.color = 0xFFCC00;
			addChild(_lblNetAmount);
			
			createHeaders();
		}
		
		private function onClickClose(event:Event):void
		{
//			if (PopUpManager.isPopUp(this))
//				PopUpManager.removePopUp(this);
			this.removeFromParent();
		}
		
		private function cleanup():void
		{
			_container.removeChildren(0, -1, true);
		}
		
		public function refresh(history:Array, historyGameId:Array):void
		{
			trace ("Trace History data here ")
			
			cleanup();
						
			var yPos:int = 0;

			var netTotalChips:int = 0;
			var result:Number;
			for (var i:int = 0; i < history.length; i++)
			{
				var playerSettlement:PlayerSettlementImpl = history[i];
					
				var row:Sprite = createRow((i+1).toString(), playerSettlement, historyGameId[i]);
				row.x = 5;
				row.y = yPos;
				_container.addChild(row);
				yPos += row.height + 4;
				
				if (playerSettlement.currentScore == 0)
					netTotalChips += playerSettlement.wonorloss;
				else
					netTotalChips -= playerSettlement.wonorloss;
			}
			result	= Number((netTotalChips / 100).toFixed(2));
			
			_lblNetAmount.text = result>0?"+ "+result:""+result;
			_container.scrollToPosition(_container.maxHorizontalScrollPosition, _container.maxVerticalScrollPosition);
		}
		
		private static function createRow(firstItem:String, playerSettlement:PlayerSettlementImpl, gameId:int):Sprite
		{
			const spaceForNames:int = 400;
			
			var row:Sprite = new Sprite();
			
			// round/deal count
			var box:Sprite = DrawShapeUtil.getBoxWithBorderWithSprite(35, 30, 0x2b2b2b, 0xffffff, 1);
			row.addChild(box);
			var label:TextField = createLabel(firstItem.toString());
			label.x = (box.width - label.width) / 2;
			label.y = box.height / 2;
			row.addChild(label);
			
			// boxes for scores
			var averageWidth:int = spaceForNames / 5;
			for (var i:int = 0; i < 4; i++)
			{
				var xPos:int = i==0?35:45 + averageWidth * i;
				box = DrawShapeUtil.getBoxWithBorderWithSprite(i==0?averageWidth+10:averageWidth, 30, 0x2b2b2b, 0xffffff, 1);
				box.x = xPos;
				row.addChild(box);
				
				var labelSring:String;
				
				switch(i)
				{
					case 0:
					{
						labelSring = gameId.toString();
						break;
					}
						
					case 1:
					{						
						if (playerSettlement.state == PlayerState.DROPPED || playerSettlement.state == PlayerState.FIRST_DROP)
							labelSring = "Drop";
						
						else if (playerSettlement.state == PlayerState.MIDDLE_DROP)
							labelSring = "M.Drop";
								
						else if (playerSettlement.state == PlayerState.WINNER)
							labelSring = "Won";
								
						else
							labelSring = "Lost";
						
						break;
					}
					
					case 2:
					{
						labelSring = playerSettlement.currentScore.toString();; 
						break;
					}
					
					case 3:
					{
						labelSring = (playerSettlement.currentScore == 0 ? "+" : "-" )+ Number(playerSettlement.wonorloss / 100).toFixed(2).toString();
						break;
					}
											
					default:
					{
						labelSring = "Error occured";
						break;
					}
				}
								
				label = createLabel(labelSring);
				label.x = xPos + (box.width - label.width) / 2;
				label.y = box.height / 2;
				row.addChild(label);
			}
			
			return row;
		}
		
		private static function createLabel(text:String):TextField
		{
			var textFormat:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, 13, Color.WHITE, "left");
			var label:TextField = new TextField(1, 1, text, textFormat);
			label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			label.alignPivot("left", "center");
			label.width = 110;
			return label;
		}
		
		private function createHeaders():void
		{
			const spaceForNames:int = 400;
			
			var row:Sprite = new Sprite();
			
			// round/deal count
			var box:Sprite = DrawShapeUtil.getBoxWithBorderWithSprite(40, 30, 0x2b2b2b, 0xffffff, 1);
			row.addChild(box);
			var label:TextField = createLabel("S.No.");
			label.x = (box.width - label.width) / 2;
			label.y = box.height / 2;
			row.addChild(label);
			
			// boxes for scores
			var averageWidth:int = spaceForNames / 5;
			for (var i:int = 0; i < 4; i++)
			{
				var xPos:int = i==0?35:45 + averageWidth * i;
				box = DrawShapeUtil.getBoxWithBorderWithSprite(i==0?averageWidth+10:averageWidth, 30, 0x2b2b2b, 0xffffff, 1);
				box.x = xPos;
				row.addChild(box);
				
				var labelSring:String;
				
				switch(i)
				{
					case 0:
					{
						labelSring = "Game Id";
						break;
					}
						
					case 1:
					{						
						labelSring = "Result";
						
						break;
					}
						
					case 2:
					{
						labelSring = "Score"; 
						break;
					}
						
					case 3:
					{
						labelSring = "Tot. Chips";
						break;
					}
				}
				
				label = createLabel(labelSring);
				label.x = xPos + (box.width - label.width) / 2;
				label.y = box.height / 2;
				row.addChild(label);
			}
			
			row.x = 12;
			row.y = 25;
			addChild(row);
		}	
	}
}