/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class MatchImpl implements SerializableSFSType{ 

	 private var _matchplayer:Array = new Array();
	 private var _lastStartTurn:int;
	 private var _deal:DealImpl;
	 private var _dealCount:int;
	 private var _id:Number;

    public function get matchplayer():Array{
           return  _matchplayer
		}



    public function set matchplayer(parrm:Array):void {
		_matchplayer = parrm; 
	}


    public function get lastStartTurn():int{
           return  _lastStartTurn
		}



    public function set lastStartTurn(parrm:int):void {
		_lastStartTurn = parrm; 
	}


    public function get deal():DealImpl{
           return  _deal
		}



    public function set deal(parrm:DealImpl):void {
		_deal = parrm; 
	}


    public function get dealCount():int{
           return  _dealCount
		}



    public function set dealCount(parrm:int):void {
		_dealCount = parrm; 
	}


    public function get id():Number{
           return  _id
		}



    public function set id(parrm:Number):void {
		_id = parrm; 
	}


	}
}
