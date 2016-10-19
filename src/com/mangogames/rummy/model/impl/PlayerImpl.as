/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class PlayerImpl implements SerializableSFSType{ 

	 private var _type:int;
	 private var _name:String;
	 private var _uidSrc:String;
	 private var _xp:int;
	 private var _level:int;
	 private var _chips:int;
	 private var _botPlayer:BotPlayerImpl;
	 private var _id:Number;
	 private var _source:int;
	 private var _wallet:int;
	 private var _buyIn:int;
	 private var _state:int;
	 private var _iconurl:String;
	 private var _showInjectors:Boolean;

    public function get type():int{
           return  _type
		}



    public function set type(parrm:int):void {
		_type = parrm; 
	}


    public function get name():String{
           return  _name
		}



    public function set name(parrm:String):void {
		_name = parrm; 
	}


    public function get uidSrc():String{
           return  _uidSrc
		}



    public function set uidSrc(parrm:String):void {
		_uidSrc = parrm; 
	}


    public function get xp():int{
           return  _xp
		}



    public function set xp(parrm:int):void {
		_xp = parrm; 
	}


    public function get level():int{
           return  _level
		}



    public function set level(parrm:int):void {
		_level = parrm; 
	}


    public function get chips():int{
           return  _chips
		}



    public function set chips(parrm:int):void {
		_chips = parrm; 
	}


    public function get botPlayer():BotPlayerImpl{
           return  _botPlayer
		}



    public function set botPlayer(parrm:BotPlayerImpl):void {
		_botPlayer = parrm; 
	}


    public function get id():Number{
           return  _id
		}



    public function set id(parrm:Number):void {
		_id = parrm; 
	}


    public function get source():int{
           return  _source
		}



    public function set source(parrm:int):void {
		_source = parrm; 
	}
	
	
	public function get wallet():int {
		return _wallet;
	}
	
	public function set wallet(parrm:int):void {
		_wallet = parrm;
	}

	 public function get buyIn():int
	 {
		 return _buyIn;
	 }

	 public function set buyIn(value:int):void
	 {
		 _buyIn = value;
	 }

	 public function get state():int
	 {
		 return _state;
	 }

	 public function set state(value:int):void
	 {
		 _state = value;
	 }

	 public function get iconurl():String
	 {
		 return _iconurl;
	 }

	 public function set iconurl(value:String):void
	 {
		 _iconurl = value;
	 }
	 
	 public function get showInjectors():Boolean
	 {
		 return _showInjectors;
	 }
	 
	 public function set showInjectors(value:Boolean):void
	 {
		 _showInjectors = value;
	 }


	}
}
