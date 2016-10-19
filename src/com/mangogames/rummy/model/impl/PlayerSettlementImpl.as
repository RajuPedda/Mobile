/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class PlayerSettlementImpl implements SerializableSFSType{ 

	 private var _xp:int;
	 private var _seatId:int;
	 private var _totalScore:int;
	 private var _currentScore:int;
	 private var _state:int;
	 private var _playerId:Number;
	 private var _handCards:HandCardsImpl;
	 private var _balance:int;
	 private var _wonorloss:int;

    public function get xp():int{
           return  _xp
		}



    public function set xp(parrm:int):void {
		_xp = parrm; 
	}


    public function get seatId():int{
           return  _seatId
		}



    public function set seatId(parrm:int):void {
		_seatId = parrm; 
	}


    public function get totalScore():int{
           return  _totalScore
		}



    public function set totalScore(parrm:int):void {
		_totalScore = parrm; 
	}


    public function get currentScore():int{
           return  _currentScore
		}



    public function set currentScore(parrm:int):void {
		_currentScore = parrm; 
	}


    public function get state():int{
           return  _state
		}



    public function set state(parrm:int):void {
		_state = parrm; 
	}


    public function get playerId():Number{
           return  _playerId
		}



    public function set playerId(parrm:Number):void {
		_playerId = parrm; 
	}


    public function get handCards():HandCardsImpl{
           return  _handCards
		}



    public function set handCards(parrm:HandCardsImpl):void {
		_handCards = parrm; 
	}

	 public function get balance():int
	 {
		 return _balance;
	 }

	 public function set balance(value:int):void
	 {
		 _balance = value;
	 }

	 public function get wonorloss():int
	 {
		 return _wonorloss;
	 }

	 public function set wonorloss(value:int):void
	 {
		 _wonorloss = value;
	 }


	}
}
