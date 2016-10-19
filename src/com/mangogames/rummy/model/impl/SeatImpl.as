/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class SeatImpl implements SerializableSFSType{ 

	 private var _player:PlayerImpl;
	 private var _seatId:int;
	 private var _card:CardImpl;

	 public function get card():CardImpl
	 {
		 return _card;
	 }

	 public function set card(value:CardImpl):void
	 {
		 _card = value;
	 }

    public function get player():PlayerImpl{
           return  _player
		}



    public function set player(parrm:PlayerImpl):void {
		_player = parrm; 
	}


    public function get seatId():int{
           return  _seatId
		}



    public function set seatId(parrm:int):void {
		_seatId = parrm; 
	}


	}
}
