/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class MatchSettlementImpl implements SerializableSFSType{ 

	 private var _isWinner:Boolean;
	 private var _winnerId:Number;
	 private var _playersSettlement:Array = new Array();
	 private var _playerState:int;
	 private var _timer:int;
	 private var _bnWinners:String = "";

    public function get isWinner():Boolean{
           return  _isWinner
		}



    public function set isWinner(parrm:Boolean):void {
		_isWinner = parrm; 
	}


    public function get winnerId():Number{
           return  _winnerId
		}



    public function set winnerId(parrm:Number):void {
		_winnerId = parrm; 
	}


    public function get playersSettlement():Array{
           return  _playersSettlement
		}



    public function set playersSettlement(parrm:Array):void {
		_playersSettlement = parrm; 
	}


    public function get playerState():int{
           return  _playerState
		}



    public function set playerState(parrm:int):void {
		_playerState = parrm; 
	}

	 public function get timer():int
	 {
		 return _timer;
	 }

	 public function set timer(value:int):void
	 {
		 _timer = value;
	 }
	 
	 public function get bnWinners():String
	 {
		 return _bnWinners;
	 }
	 
	 public function set bnWinners(value:String):void
	 {
		 _bnWinners = value;
	 }


	}
}
