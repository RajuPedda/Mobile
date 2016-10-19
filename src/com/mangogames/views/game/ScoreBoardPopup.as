package com.mangogames.views.game
{
	import com.mangogames.managers.MangoAssetManager;
	import com.mangogames.models.IGame;
	import com.mangogames.rummy.model.impl.DealImpl;
	import com.mangogames.rummy.model.impl.MatchImpl;
	import com.mangogames.rummy.model.impl.MatchPlayerImpl;
	import com.mangogames.rummy.model.impl.PlayerImpl;
	import com.mangogames.rummy.model.impl.ScoreImpl;
	import com.mangogames.rummy.model.impl.SyndicateGameImpl;
	import com.mangogames.rummy.model.util.GameUtil;
	import com.mangogames.services.SFSInterface;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ScrollContainer;
	import feathers.core.PopUpManager;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import utils.DrawShapeUtil;
	import utils.Fonts;
	import utils.ScaleUtils;

	/**
	 * 
	 * @author Raju Pedda .M
	 * 
	 */	
	public class ScoreBoardPopup extends Sprite
	{
		public function ScoreBoardPopup(match:MatchImpl)
		{
			super();
			initScreen(match);
		}
		
		private var _container:ScrollContainer;
		private var bg:Image;
		
		override public function dispose():void
		{
			cleanup();
			
			super.dispose();
		}
		
		private function initScreen(match:MatchImpl):void
		{
			var bgTexture:Texture	= MangoAssetManager.I.getTexture("history_popup");
			//var rect:Rectangle = new Rectangle( 10, 30, 60, 60 );
			// textures:Scale9Textures = new Scale9Textures( bgTexture, rect );
			
			//bg = new Scale9Image( textures, 1 );
			bg	= new Image(bgTexture);
			bg.scale9Grid	= new Rectangle( 10, 30, 60, 60 );
			
			if(match && match.matchplayer)
			{
				if(match.matchplayer.length >= 5)
				{
					bg.width = 570;
					bg.height = 310;
				}
			}
		//	bg.smoothing	= TextureSmoothing.NONE;
			this.addChild( bg )
			
			
			
			/*var bg:Image = new Image(MangoAssetManager.I.getTexture("history_popup"));
			addChild(bg);*/
			
			var btnClose:Button = new Button(MangoAssetManager.I.getTexture("close_btn"));
			addChild(btnClose);
			btnClose.x = bg.width - btnClose.width - 5;
			btnClose.y = 2;
			btnClose.addEventListener(Event.TRIGGERED, onClickClose);
			
			_container = new ScrollContainer();
			addChild(_container);
			_container.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
			_container.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_ON;
			_container.x = 0;
			_container.y = 25;
			_container.width = bg.width-12;
			_container.height = bg.height - 35;
		}
		
		private function onClickClose(event:Event):void
		{
			if (PopUpManager.isPopUp(this))
				PopUpManager.removePopUp(this);
		}
		
		private function cleanup():void
		{
			_container.removeChildren(0, -1, true);
		}
		
		private function isMaxLimitCrossed(game:IGame, score:int):Boolean
		{
			var isSyndicateGame:Boolean	= game is SyndicateGameImpl;
			if(!isSyndicateGame)
				return false;
			if((game as SyndicateGameImpl).maxScore== 101 && score == 102 || (game as SyndicateGameImpl).maxScore== 201 && score == 202)
			{
				return true;
			}
			return false;
		}
		
		public function refresh(game:IGame, match:MatchImpl, deal:DealImpl):void
		{
			cleanup();
			
			if (!game || !match || !match.matchplayer || match.matchplayer.length < 1)
				return;
			
			
			// FIXME: a lame way to implement things, too many loops
			// FIXME: ideally a proper list of score should come from server
			// create columns of items first
			var columns:Array = new Array();
			for (var i:int = 0; i < match.matchplayer.length; i++)
			{
				var matchPlayer:MatchPlayerImpl = match.matchplayer[i];
				var player:PlayerImpl = GameUtil.getPlayerById(game, matchPlayer.dbId);
				var playerName:String = player ? player.name : SFSInterface.getInstance().getPlayerNameById(matchPlayer.dbId);
				var column:Array = new Array(playerName);
				
				var cumulativeScore:int = 0;
				for (var j:int = 0; j < matchPlayer.score.length; j++)
				{
					var score:ScoreImpl = matchPlayer.score[j];
					var isSyndicateGame:Boolean	= game is SyndicateGameImpl;
					
					if(isSyndicateGame && isMaxLimitCrossed(game,score.score))
					{
						column.push("-");
					}
					else
					{
						if(matchPlayer.rejoinedDealNo >0 && j<matchPlayer.rejoinedDealNo)
						{
							column.push("-");
						}
						else
						{
							cumulativeScore += score.score;
							column.push(score.score);
						}
					}
				}
				if(matchPlayer.score.length == 0)
				{
					column.push("-");
					column.push(cumulativeScore);
				}
				else if(matchPlayer.score.length > match.dealCount)
				{
					column.push(cumulativeScore);
				}
				else
				{
					column.push("-");
					column.push(cumulativeScore);
				}
				
				columns.push(column);
			}
			
			// now draw them one by one
			var dealCount:int = columns[0].length; // assuming the first counts as total deal count including name
			var yPos:int = 0;
			var finalScoreList:Array = new Array();
			for (i = 0; i < dealCount; i++)
			{
				var rowItems:Array = new Array();
				
				for (j = 0; j < columns.length; j++)
				{
					column = columns[j];
					rowItems.push(column[i]);
				}
				
				if (i == 0)
					finalScoreList.unshift(createRow("RNo.", rowItems)); // push the headers to the top
				else if (i == dealCount-1)
					finalScoreList.push(createRow("Total", rowItems)); // push the total at last
				else
					finalScoreList.push(createRow(i.toString(), rowItems));
			}
			
			// finally populate the score items
			for (i = 0; i < finalScoreList.length; i++)
			{
				var row:Sprite = finalScoreList[i];
				row.x = 5;
				row.y = yPos;
				_container.addChild(row);
				yPos += row.height + 4;
			}
			_container.scrollToPosition(_container.maxHorizontalScrollPosition, _container.maxVerticalScrollPosition);
		}
		
		private static function createRow(firstItem:String, items:Array):Sprite
		{
			const spaceForNames:int = 328;
			
			var row:Sprite = new Sprite();
			
			// round/deal count
			var box:Sprite = DrawShapeUtil.getBoxWithBorderWithSprite(45, 30, 0x2b2b2b, 0xffffff, 1);
			row.addChild(box);
			var label:TextField = createLabel(firstItem.toString());
			label.x = (box.width - label.width) / 2;
			label.y = box.height / 2;
			row.addChild(label);
			
			// boxes for scores
			var averageWidth:int = spaceForNames / items.length;
			
			if(items.length ==5)
				averageWidth	= 95;
			else if(items.length == 6)
				averageWidth	= 78;
			
			for (var i:int = 0; i < items.length; i++)
			{
				var xPos:int = 45 + averageWidth * i;
				box = DrawShapeUtil.getBoxWithBorderWithSprite(averageWidth, 30, 0x2b2b2b, 0xffffff, 1);
				box.x = xPos;
				row.addChild(box);
				if(items[i]!=undefined)
				{
					label = createLabel(items[i].toString());
					label.x = xPos + (box.width - label.width) / 2;
					label.y = box.height / 2;
					row.addChild(label);
				}
			}
			
			return row;
		}
		
		private static function createLabel(text:String):TextField
		{
			var fontSize:int	= ScaleUtils.scaleFactorNoBorder >1? 16*ScaleUtils.scaleFactorNoBorder : 14;
			
			var tf:TextFormat	= new TextFormat(Fonts.getInstance().fontRegular, fontSize, Color.WHITE);
			var label:TextField = new TextField(1, 1, text, tf);
			label.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			label.alignPivot("left", "center");
			return label;
		}
	}
}