/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class DealImpl implements SerializableSFSType{ 

	 private var _currentTurn:int;
	 private var _joker:JokerImpl;
	 private var _showInitiator:Number;
	 private var _closeddeck:ClosedDeckImpl;
	 private var _dealplayer:Array = new Array();
	 private var _dealNumber:int;
	 private var _opendeck:OpenDeckImpl;
	 private var _gameprize:int;

    public function get currentTurn():int{
           return  _currentTurn
		}



    public function set currentTurn(parrm:int):void {
		_currentTurn = parrm; 
	}


    public function get joker():JokerImpl{
           return  _joker
		}



    public function set joker(parrm:JokerImpl):void {
		_joker = parrm; 
	}


    public function get showInitiator():Number{
           return  _showInitiator
		}



    public function set showInitiator(parrm:Number):void {
		_showInitiator = parrm; 
	}


    public function get closeddeck():ClosedDeckImpl{
           return  _closeddeck
		}



    public function set closeddeck(parrm:ClosedDeckImpl):void {
		_closeddeck = parrm; 
	}


    public function get dealplayer():Array{
           return  _dealplayer
		}



    public function set dealplayer(parrm:Array):void {
		_dealplayer = parrm; 
	}


    public function get dealNumber():int{
           return  _dealNumber
		}



    public function set dealNumber(parrm:int):void {
		_dealNumber = parrm; 
	}


    public function get opendeck():OpenDeckImpl{
           return  _opendeck
		}



    public function set opendeck(parrm:OpenDeckImpl):void {
		_opendeck = parrm; 
	}
	
	public function get gameprize():int
	{
		 return _gameprize;
	}
	
	public function set gameprize(value:int):void
	{
		_gameprize = value;
	}
	}
}
