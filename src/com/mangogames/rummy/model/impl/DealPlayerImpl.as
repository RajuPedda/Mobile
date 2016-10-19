/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2013/12/11 10:51:00 
*/

package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;

public class DealPlayerImpl implements SerializableSFSType{ 


	 private var _winner:Boolean;
	 private var _score:ScoreImpl;
	 private var _dbId:Number;
	 private var _handcards:HandCardsImpl;
	 private var _missedTurnCount:int;
	 private var _state:int;
	 private var _timeOfJoining:String;
	 private var _wonorloss:Number;
	 private var _totalScore:int;


    public function get winner():Boolean{
           return  _winner
		}



    public function set winner(parrm:Boolean):void {
		_winner = parrm; 
	}


    public function get score():ScoreImpl{
           return  _score
		}



    public function set score(parrm:ScoreImpl):void {
		_score = parrm; 
	}


    public function get dbId():Number{
           return  _dbId
		}



    public function set dbId(parrm:Number):void {
		_dbId = parrm; 
	}


    public function get handcards():HandCardsImpl{
           return  _handcards
		}



    public function set handcards(parrm:HandCardsImpl):void {
		_handcards = parrm; 
	}


    public function get missedTurnCount():int{
           return  _missedTurnCount
		}



    public function set missedTurnCount(parrm:int):void {
		_missedTurnCount = parrm; 
	}


    public function get state():int{
           return  _state
		}



    public function set state(parrm:int):void {
		_state = parrm; 
	}


    public function get timeOfJoining():String{
           return  _timeOfJoining
		}



    public function set timeOfJoining(parrm:String):void {
		_timeOfJoining = parrm; 
	}

	 public function get wonorloss():Number
	 {
		 return _wonorloss;
	 }

	 public function set wonorloss(value:Number):void
	 {
		 _wonorloss = value;
	 }

	 public function get totalScore():int
	 {
		 return _totalScore;
	 }

	 public function set totalScore(value:int):void
	 {
		 _totalScore = value;
	 }


	}
}

