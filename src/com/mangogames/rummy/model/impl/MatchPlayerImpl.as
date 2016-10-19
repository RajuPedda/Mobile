/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class MatchPlayerImpl implements SerializableSFSType{ 

	 private var _score:Array = new Array();
	 private var _settlement:SettlementImpl;
	 private var _dbId:Number;
	 private var _tossRank:int;
	 private var _state:int;
	 private var _timeOfJoining:int;
	 private var _rejoinedDealNo:int;

    public function get score():Array{
           return  _score
		}



    public function set score(parrm:Array):void {
		_score = parrm; 
	}


    public function get settlement():SettlementImpl{
           return  _settlement
		}



    public function set settlement(parrm:SettlementImpl):void {
		_settlement = parrm; 
	}


    public function get dbId():Number{
           return  _dbId
		}



    public function set dbId(parrm:Number):void {
		_dbId = parrm; 
	}


    public function get tossRank():int{
           return  _tossRank
		}



    public function set tossRank(parrm:int):void {
		_tossRank = parrm; 
	}


    public function get state():int{
           return  _state
		}



    public function set state(parrm:int):void {
		_state = parrm; 
	}


    public function get timeOfJoining():int{
           return  _timeOfJoining
		}



    public function set timeOfJoining(parrm:int):void {
		_timeOfJoining = parrm; 
	}

	public function totalScore():int
	{
		var tot:int =0;
		
		for each(var scores:ScoreImpl in score)
		{
			tot	+= scores.score;
		}
		return tot;
	}

	 public function get rejoinedDealNo():int
	 {
		 return _rejoinedDealNo;
	 }

	 public function set rejoinedDealNo(value:int):void
	 {
		 _rejoinedDealNo = value;
	 }


	}
}
