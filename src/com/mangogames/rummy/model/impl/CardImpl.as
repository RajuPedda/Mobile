/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class CardImpl implements SerializableSFSType{ 

	 private var _suit:int;
	 private var _rank:int;
	 private var _ispaperjoker:int;

    public function get suit():int{
           return  _suit
		}



    public function set suit(parrm:int):void {
		_suit = parrm; 
	}


    public function get rank():int{
           return  _rank
		}



    public function set rank(parrm:int):void {
		_rank = parrm; 
	}

	 public function get ispaperjoker():int
	 {
		 return _ispaperjoker;
	 }

	 public function set ispaperjoker(value:int):void
	 {
		 _ispaperjoker = value;
	 }


	}
}
