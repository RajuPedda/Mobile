/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2014/01/03 15:18:47 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class ScoreImpl implements SerializableSFSType{ 

	 private var _dealnum:Number;
	 private var _score:int;

    public function get dealnum():Number{
           return  _dealnum
		}



    public function set dealnum(parrm:Number):void {
		_dealnum = parrm; 
	}


    public function get score():int{
           return  _score
		}



    public function set score(parrm:int):void {
		_score = parrm; 
	}


	}
}
