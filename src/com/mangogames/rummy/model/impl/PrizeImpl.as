/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class PrizeImpl implements SerializableSFSType{ 

	 private var _goodie:String;
	 private var _prizeName:String;
	 private var _currency:String;
	 private var _xP:String;

    public function get goodie():String{
           return  _goodie
		}



    public function set goodie(parrm:String):void {
		_goodie = parrm; 
	}


    public function get prizeName():String{
           return  _prizeName
		}



    public function set prizeName(parrm:String):void {
		_prizeName = parrm; 
	}


    public function get currency():String{
           return  _currency
		}



    public function set currency(parrm:String):void {
		_currency = parrm; 
	}


    public function get xP():String{
           return  _xP
		}



    public function set xP(parrm:String):void {
		_xP = parrm; 
	}


	}
}
