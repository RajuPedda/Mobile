package com.mangogames.models
{
	public interface IGame
	{
		 function set dbId(value:Number):void
		 function get dbId():Number
		 function get minPlayersRequired():int
		 function set minPlayersRequired(parrm:int):void 
		 function get maxSpectators():int
		 function set maxSpectators(parrm:int):void 
		 function get user():Array
		 function set user(parrm:Array):void 
		 function get useBot():int
		 function set useBot(parrm:int):void
		 function get defId():int
		 function set defId(parrm:int):void
		 function get maxPlayers():int
		 function set maxPlayers(parrm:int):void
		 function get id():Number
		 function set id(parrm:Number):void 
		 function set typeId(parrm:int):void 
		 function get seat():Array
		 function set seat(parrm:Array):void
		 function get dynamic():Boolean
		 function set dynamic(parrm:Boolean):void 
	}
}