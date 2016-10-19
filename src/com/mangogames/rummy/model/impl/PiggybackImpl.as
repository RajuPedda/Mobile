/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class PiggybackImpl implements SerializableSFSType{ 

	 private var _actionId:int;
	 private var _xp:int;
	 private var _skuId:int;
	 private var _updateInv:int;
	 private var _subproductId:int;
	 private var _gold:int;
	 private var _subActionId:int;
	 private var _level:int;
	 private var _chips:Number;
	 private var _noOfPlayers:int;
	 private var _seatid:int;
	 private var _realMoney:int;

    public function get actionId():int{
           return  _actionId
		}



    public function set actionId(parrm:int):void {
		_actionId = parrm; 
	}


    public function get xp():int{
           return  _xp
		}



    public function set xp(parrm:int):void {
		_xp = parrm; 
	}


    public function get skuId():int{
           return  _skuId
		}



    public function set skuId(parrm:int):void {
		_skuId = parrm; 
	}


    public function get updateInv():int{
           return  _updateInv
		}



    public function set updateInv(parrm:int):void {
		_updateInv = parrm; 
	}


    public function get subproductId():int{
           return  _subproductId
		}



    public function set subproductId(parrm:int):void {
		_subproductId = parrm; 
	}


    public function get gold():int{
           return  _gold
		}



    public function set gold(parrm:int):void {
		_gold = parrm; 
	}


    public function get subActionId():int{
           return  _subActionId
		}



    public function set subActionId(parrm:int):void {
		_subActionId = parrm; 
	}


    public function get level():int{
           return  _level
		}



    public function set level(parrm:int):void {
		_level = parrm; 
	}


    public function get chips():Number{
           return  _chips
		}



    public function set chips(parrm:Number):void {
		_chips = parrm; 
	}


    public function get noOfPlayers():int{
           return  _noOfPlayers
		}



    public function set noOfPlayers(parrm:int):void {
		_noOfPlayers = parrm; 
	}

	 public function get seatid():int
	 {
		 return _seatid;
	 }

	 public function set seatid(value:int):void
	 {
		 _seatid = value;
	 }
	 
	 public function get realMoney():int
	 {
		 return _realMoney;
	 }
	 
	 public function set realMoney(value:int):void
	 {
		 _realMoney = value;
	 }


	}
}
