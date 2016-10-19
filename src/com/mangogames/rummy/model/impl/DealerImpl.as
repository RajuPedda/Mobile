/* 	This code is generated automatically from its corresponding Java model code. 
	Do not modify this code, as all modifications will be overwriiten. 
	Date generated: 2013/08/12 18:03:33 
*/
package com.mangogames.rummy.model.impl 
{
import com.smartfoxserver.v2.protocol.serialization.SerializableSFSType;
public class DealerImpl implements SerializableSFSType{ 

	 private var _handCards:CardContainerImpl;
	 private var _nTimesQualified:int;
	 private var _chipsWon:Number;

    public function get handCards():CardContainerImpl{
           return  _handCards
		}



    public function set handCards(parrm:CardContainerImpl):void {
		_handCards = parrm; 
	}


    public function get nTimesQualified():int{
           return  _nTimesQualified
		}



    public function set nTimesQualified(parrm:int):void {
		_nTimesQualified = parrm; 
	}


    public function get chipsWon():Number{
           return  _chipsWon
		}



    public function set chipsWon(parrm:Number):void {
		_chipsWon = parrm; 
	}


	}
}
