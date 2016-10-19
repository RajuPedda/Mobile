/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.mangogames.models.IGame;
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;

public class BestOfNGameImpl implements IGame, SerializableSFSType
{ 

	 private var _format:int;
	 private var _owner:String;
	 private var _minPlayersRequired:int;
	 private var _maxSpectators:int;
	 private var _entryFee:Number;
	 private var _user:Array = new Array();
	 private var _dbId:Number;
	 private var _dropPts:int;
	 private var _useBot:int;
	 private var _defId:int;
	 private var _maxPlayers:int;
	 private var _potValue:int;
	 private var _maxScore:int;
	 private var _rake:Number;
	 private var _id:Number;
	 private var _prize:PrizeImpl;
	 private var _seat:Array = new Array();
	 private var _type:int;
	 private var _dynamic:Boolean;
	 private var _typeId:int

	 public function get typeId():int
	 {
		 return _typeId;
	 }

	 public function set typeId(value:int):void
	 {
		 _typeId = value;
	 }

    public function get format():int{
           return  _format
		}



    public function set format(parrm:int):void {
		_format = parrm; 
	}


    public function get owner():String{
           return  _owner
		}



    public function set owner(parrm:String):void {
		_owner = parrm; 
	}


    public function get minPlayersRequired():int{
           return  _minPlayersRequired
		}



    public function set minPlayersRequired(parrm:int):void {
		_minPlayersRequired = parrm; 
	}


    public function get maxSpectators():int{
           return  _maxSpectators
		}



    public function set maxSpectators(parrm:int):void {
		_maxSpectators = parrm; 
	}


    public function get entryFee():Number{
           return  _entryFee
		}



    public function set entryFee(parrm:Number):void {
		_entryFee = parrm; 
	}


    public function get user():Array{
           return  _user
		}



    public function set user(parrm:Array):void {
		_user = parrm; 
	}


    public function get dbId():Number{
           return  _dbId
		}



    public function set dbId(parrm:Number):void {
		_dbId = parrm; 
	}


    public function get dropPts():int{
           return  _dropPts
		}



    public function set dropPts(parrm:int):void {
		_dropPts = parrm; 
	}


    public function get useBot():int{
           return  _useBot
		}



    public function set useBot(parrm:int):void {
		_useBot = parrm; 
	}


    public function get defId():int{
           return  _defId
		}



    public function set defId(parrm:int):void {
		_defId = parrm; 
	}


    public function get maxPlayers():int{
           return  _maxPlayers
		}



    public function set maxPlayers(parrm:int):void {
		_maxPlayers = parrm; 
	}


    public function get potValue():int{
           return  _potValue
		}



    public function set potValue(parrm:int):void {
		_potValue = parrm; 
	}


    public function get maxScore():int{
           return  _maxScore
		}



    public function set maxScore(parrm:int):void {
		_maxScore = parrm; 
	}


    public function get rake():Number{
           return  _rake
		}



    public function set rake(parrm:Number):void {
		_rake = parrm; 
	}


    public function get id():Number{
           return  _id
		}



    public function set id(parrm:Number):void {
		_id = parrm; 
	}


    public function get prize():PrizeImpl{
           return  _prize
		}



    public function set prize(parrm:PrizeImpl):void {
		_prize = parrm; 
	}


    public function get seat():Array{
           return  _seat
		}



    public function set seat(parrm:Array):void {
		_seat = parrm; 
	}


    public function get type():int{
           return  _type
		}



    public function set type(parrm:int):void {
		_type = parrm; 
	}


    public function get dynamic():Boolean{
           return  _dynamic
		}



    public function set dynamic(parrm:Boolean):void {
		_dynamic = parrm; 
	}


	}
}
