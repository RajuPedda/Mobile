package utils
{
	import flash.utils.getTimer;
	
	public class Sorter
	{
		private static const TRACK_TIME:Boolean = false;
		
		public static const SORTTYPE_NONE:int = 0;
		public static const SORTTYPE_PURE:int = 1;
		public static const SORTTYPE_IMPURE:int = 2;
		public static const SORTTYPE_SET:int = 3;
		
		// containers
		private static var _pureSequences:Vector.<Vector.<IMangoCard>>;
		private static var _impureSequences:Vector.<Vector.<IMangoCard>>;
		private static var _sets:Vector.<Vector.<IMangoCard>>;
		private static var _unsortedCards:Vector.<Vector.<IMangoCard>>;
		
		public static function sortBySequence(handCards:Vector.<Vector.<IMangoCard>>, jokerRank:int):Vector.<Vector.<IMangoCard>>
		{
			if (!jokerRank < 0 || !jokerRank > 12)
				throw new Error("Joker not specified! Please set joker before sort");
			
			resetContainers();
			//filterExistingPureSequences(handCards);
			var allCards:Vector.<IMangoCard> = gatherAllCards(handCards);
			
			// step 1: sort/categorize all cards by their suit
			var cardInSuits:Vector.<Vector.<IMangoCard>> = new Vector.<Vector.<IMangoCard>>();
			cardInSuits.push(new Vector.<IMangoCard>());
			cardInSuits.push(new Vector.<IMangoCard>());
			cardInSuits.push(new Vector.<IMangoCard>());
			cardInSuits.push(new Vector.<IMangoCard>());
			
			for (var i:int = 0; i < allCards.length; i++)
			{
				switch (allCards[i].suit)
				{
					case 0: cardInSuits[0].push(allCards[i]); break;
					case 1: cardInSuits[1].push(allCards[i]); break;
					case 2: cardInSuits[2].push(allCards[i]); break;
					case 3: cardInSuits[3].push(allCards[i]); break;
				}
			}
			
			// step 2: sort cards in each of these suits by their rank
			for (i = 0; i < cardInSuits.length; i++)
			{
				cardInSuits[i].sort(simpleSortByRank);
			}
			
			// step 3: try to find pure sequences within these sorted group of cards
			for (i = 0; i < cardInSuits.length; i++)
			{
				var suitGroup:Vector.<IMangoCard> = cardInSuits[i];
				
				// directly put suits having less than 3 cards in unsorted list
				if (suitGroup.length < 3)
				{
					_unsortedCards.push(suitGroup);
					continue;
				}
				
				filterSequences(suitGroup, null);
			}
			
			// step 4: try to form impure sequences with left-over cards
			// fetch all available jokers
			var jokers:Vector.<IMangoCard> = gatherAllJokers(_unsortedCards, jokerRank);
			if (jokers.length > 0)
			{
				var tempGroups:Vector.<Vector.<IMangoCard>> = _unsortedCards;
				_unsortedCards = new Vector.<Vector.<IMangoCard>>();
				while (tempGroups.length != 0)
				{
					var groupCard:Vector.<IMangoCard> = tempGroups.shift();
					if (groupCard.length < 2)
					{
						_unsortedCards.push(groupCard);
						continue;
					}
					
					filterSequences(groupCard, jokers);
				}
			}
			
			// add back any leftover jokers
			if (jokers.length > 0)
				_unsortedCards.push(jokers);
			
			// gather singles
			gatherSingles();
			
			// prepare final hand cards
			var sortedHandCards:Vector.<Vector.<IMangoCard>> = new Vector.<Vector.<IMangoCard>>();
			mergeGroupIntoHandCards(_pureSequences, sortedHandCards);
			mergeGroupIntoHandCards(_impureSequences, sortedHandCards);
			//mergeGroupIntoHandCards(_sets, sortedHandCards);
			mergeGroupIntoHandCards(_unsortedCards, sortedHandCards);
			
			return sortedHandCards;
		}
		
		private static function filterExistingPureSequences(handCards:Vector.<Vector.<IMangoCard>>):void
		{
			for (var i:int = 0; i < handCards.length; i++)
			{
				var groupCard:Vector.<IMangoCard> = handCards[i];
				if (isPureSequence(groupCard))
				{
					_pureSequences.push(groupCard);
					handCards.splice(i, 1);
					i--;
				}
			}
		}
		
		private static function filterSequences(cards:Vector.<IMangoCard>, jokers:Vector.<IMangoCard>):void
		{
			var sequence:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			sequence.push(cards.shift()); // start sequence with the first most card
			var unsequencedCards:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			var isPure:Boolean = true;
			
			do
			{
				var lastCard:IMangoCard = sequence[sequence.length - 1];
				var currentCard:IMangoCard = cards.shift();
				
				if (currentCard && !lastCard.isPaperJoker > 0)
				{
					var diff:int = currentCard.rank - lastCard.rank; // rank difference
					
					// duplicate
					if (diff == 0)
					{
						unsequencedCards.push(currentCard);
						continue;
					}
					
					// normal sequence
					if (diff == 1)
					{
						sequence.push(currentCard);
						continue;
					}
					
					// try sequence with jokers
					if (jokers && jokers.length > 0 && diff > 1 && jokers.length >= diff - 1)
					{
						// consume these many jokers
						sequence = sequence.concat(jokers.splice(0, diff - 1));
						sequence.push(currentCard);
						isPure = false;
						continue;
					}
				}
				
				// special: Q-K-A sequence
				var lastUnsequencedCard:IMangoCard = unsequencedCards.length > 0 ? unsequencedCards[0] : null;
				if ((lastUnsequencedCard && lastUnsequencedCard.rank == 0) &&
					(lastCard.rank == 11 || lastCard.rank == 12) &&
					(!lastUnsequencedCard.isPaperJoker > 0 && !lastCard.isPaperJoker > 0))
				{
					// pure Q-K-A, make sure that last 2 cards are Q and K
					if (lastCard.rank == 12 && sequence.length > 1 && sequence[sequence.length - 2].rank == 11)
					{
						sequence.push(unsequencedCards.shift());
						if (currentCard)
							cards.unshift(currentCard); // put back current card
						continue;
					}
					
					// impure Q-K-A, try to fillup one card with joker
					if (jokers && jokers.length > 0)
					{
						// there is a valid Q-K-A sequence with help of a joker
						if (lastCard.rank == 11)
						{
							// Q-JOKER-A
							sequence.push(jokers.shift());
						}
						else if (lastCard.rank == 12 && sequence.length == 1)
						{
							// JOKER-K-A
							sequence.pop();
							sequence.push(jokers.shift());
							sequence.push(lastCard);
						}
						sequence.push(unsequencedCards.shift());
						isPure = false;
						continue;
					}
				}
				
				// one last try with jokers
				if (sequence.length == 2 && jokers && jokers.length > 0)
				{
					// first check for Q-K-A
					if (sequence[0].rank == 12 && sequence[1].rank == 0)
						sequence.unshift(jokers.pop());
					else if (sequence[0].rank > 0)
						sequence.unshift(jokers.pop());
					else
						sequence.push(jokers.pop());
				}
				
				// sequence is broken
				if (sequence.length > 2)
				{
					if (isPure)
						_pureSequences.push(sequence);
					else
						_impureSequences.push(sequence);
				}
				else if (sequence.length > 0)
				{
					unsequencedCards = unsequencedCards.concat(sequence);
				}
				
				// current card is null only when there are no cards in the list, break the loop
				if (!currentCard)
					break;
				
				// otherwise start a new sequence
				sequence = new Vector.<IMangoCard>();
				sequence.push(currentCard);
				isPure = true;
			}
			while (cards.length >= 0);
			
			if (unsequencedCards.length > 0)
				_unsortedCards.push(unsequencedCards);
		}
		
		public static function sortBySets(handCards:Vector.<Vector.<IMangoCard>>, jokerRank:int):Vector.<Vector.<IMangoCard>>
		{
			if (!jokerRank < 0 || !jokerRank > 12)
				throw new Error("Joker not specified! Please set joker before sort");
			
			resetContainers();
			//filterExistingPureSequences(handCards);
			
			// gather all jokers before continuing
			var jokers:Vector.<IMangoCard> = gatherAllJokers(handCards, jokerRank);
			var allCards:Vector.<IMangoCard> = gatherAllCards(handCards);
			
			// step 1: sort them by rank
			allCards.sort(simpleSortByRank);
			
			// step 2: fiter out two or more cards in group
			filterSets(allCards, jokers);
			
			// add back any leftover jokers
			if (jokers.length > 0)
				_unsortedCards.push(jokers);
			
			// prepare final hand cards
			var sortedHandCards:Vector.<Vector.<IMangoCard>> = new Vector.<Vector.<IMangoCard>>();
			mergeGroupIntoHandCards(_pureSequences, sortedHandCards);
			//mergeGroupIntoHandCards(_impureSequences, sortedHandCards);
			mergeGroupIntoHandCards(_sets, sortedHandCards);
			mergeGroupIntoHandCards(_unsortedCards, sortedHandCards);
			
			return sortedHandCards;
		}
		
		private static function filterSets(cards:Vector.<IMangoCard>, jokers:Vector.<IMangoCard>):void
		{
			var newSet:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			var cardsNotInSet:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			var suitAvailable:Array = new Array(false, false, false, false);
			
			do
			{
				var currentCard:IMangoCard = cards.shift();
				var lastCard:IMangoCard = newSet.length > 0 ? newSet[newSet.length - 1] : null;
				
				if (currentCard && lastCard && currentCard.rank == lastCard.rank)
				{
					if (!suitAvailable[currentCard.suit] && newSet.length <= 4)
					{
						// rank matched
						newSet.push(currentCard);
						suitAvailable[currentCard.suit] = true;
					}
					else
					{
						// duplicate card
						cardsNotInSet.push(currentCard);
					}
					continue;
				}
				
				// if the set is not yet complete then try to complete it with
				// the help of any available joker
				if (newSet.length == 2 && jokers.length > 0)
					newSet.push(jokers.pop());
				
				// set is broken, check for valid sets
				// we are considering a 2-cards set as valid for the sake of keeping it separate
				if (newSet.length > 1)
					_sets.push(newSet); // valid set
				else if (newSet.length > 0)
					cardsNotInSet = cardsNotInSet.concat(newSet);
				
				// current card is null only when there are no cards in the list, break the loop
				if (!currentCard)
					break;
				
				// otherwise start a new set formation
				newSet = new Vector.<IMangoCard>();
				newSet.push(currentCard);
				suitAvailable = new Array(false, false, false, false);
				suitAvailable[currentCard.suit] = true;
			}
			while(cards.length >= 0);
			
			// gather all unsorted cards in a single list
			_unsortedCards.push(cardsNotInSet);
		}
		
		private static function gatherAllCards(handCards:Vector.<Vector.<IMangoCard>>):Vector.<IMangoCard>
		{
			// gather all cards and filter out any of the jokers presents in hand
			var allCards:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			for (var i:int = 0; i < handCards.length; i++)
			{
				allCards = allCards.concat(handCards[i]);
			}
			
			return allCards;
		}
		
		private static function gatherAllJokers(groupsOfCards:Vector.<Vector.<IMangoCard>>, jokerRank:int):Vector.<IMangoCard>
		{
			var allJokers:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			for (var i:int = 0; i < groupsOfCards.length; i++)
			{
				var group:Vector.<IMangoCard> = groupsOfCards[i];
				for (var j:int = 0; j < group.length;)
				{
					var card:IMangoCard = group[j];
					if (card.rank == jokerRank)
					{
						group.splice(j, 1);
						allJokers.push(card);
					}
					else
					{
						j++;
					}
				}
			}
			return allJokers;
		}
		
		private static function gatherJokersInCards(cards:Vector.<IMangoCard>, jokerRank:int):Vector.<IMangoCard>
		{
			var jokers:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			for (var i:int = 0; i < cards.length; i++)
			{
				if (cards[i].rank == jokerRank)
				{
					jokers.push(cards[i]);
					cards.splice(i, 1);
					i--;
				}
			}
			return jokers;
		}
		
		private static function gatherPaperJokers(cards:Vector.<IMangoCard>):Vector.<IMangoCard>
		{
			var jokers:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			for (var i:int = 0; i < cards.length; i++)
			{
				if (cards[i].isPaperJoker > 0)
				{
					jokers.push(cards[i]);
					cards.splice(i, 1);
					i--;
				}
			}
			return jokers;
		}
		
		private static function gatherSingles():void
		{
			var singles:Vector.<IMangoCard> = new Vector.<IMangoCard>();
			for (var i:int = 0; i < _unsortedCards.length; i++)
			{
				var groupCard:Vector.<IMangoCard> = _unsortedCards[i];
				if (groupCard.length == 1)
				{
					singles = singles.concat(groupCard);
					_unsortedCards.splice(i, 1);
					i--;
				}
			}
			
			if (singles.length > 0)
				_unsortedCards.push(singles);
		}
		
		private static function isPureSequence(cards:Vector.<IMangoCard>):Boolean
		{
			if (cards.length < 3)
				return false;
			
			cards = cards.slice();
			cards.sort(simpleSortByRank);
			
			var card:IMangoCard = cards[0];
			var prevCard:IMangoCard = null;
			for (var i:int = 1; i < cards.length; i++)
			{
				prevCard = card;
				card = cards[i];
				
				if (prevCard.suit != card.suit)
					return false;
				
				if (card.rank != prevCard.rank + 1)
				{
					// if its an ace and we have a king at the last then consider it a 
					// valid sequnce and continue with other cards
					if (prevCard.rank == 0 && cards[cards.length - 1].rank == 12)
						continue;
					
					return false;
				}
			}
			
			return true;
		}
		
		private static function isImpureSequence(cards:Vector.<IMangoCard>, jokerRank:int):Boolean
		{
			// NOTE: this method exclusively checks for impure sequences and NOT for pure,
			// so if the cards are pure, then this method will return false
			
			if (cards.length < 3)
				return false;
			
			cards = cards.slice();
			
			// first remove all the jokers
			var jokers:Vector.<IMangoCard> = gatherJokersInCards(cards, jokerRank);
			
			// if everything is a joker
			if (cards.length == 0)
				return false;
			
			// if there are no jokers in it, it can not be impure
			if (jokers.length == 0)
				return false;
			
			cards.sort(simpleSortByRank);
			
			// check for the possiblity of a QKA sequence, if the first card is an ace
			// and last card is a king or a queen then this will be a QKA sequence
			// keep track of this ace and do not use it for any further sequencing
			var goingForQKA:Boolean = false;
			if (cards[0].rank == 0 && 
				(cards[cards.length - 1].rank == 11 ||
				cards[cards.length - 1].rank == 12))
			{
				jokers.pop(); // consume a joker
				goingForQKA = true;
			}
			
			var card:IMangoCard = goingForQKA ? cards[1] : cards[0];
			var prevCard:IMangoCard = null;
			for (var i:int = goingForQKA ? 2 : 1; i < cards.length; i++)
			{
				prevCard = card;
				card = cards[i];
				
				if (prevCard.suit != card.suit)
					return false;
				
				var diff:int = card.rank - prevCard.rank;
				if (diff == 0)
					return false;
				
				if (diff == 1)
					continue;
				
				// continue using jokers
				if (jokers.length >= diff - 1)
				{
					jokers.splice(0, diff - 1);
					continue;
				}
				
				// if not going for a Q-F-A, or the diff is way more
				if (!goingForQKA || diff > 1)
					return false;
			}
			
			// now if there are still jokers available, then try to adjust it in the begining
			if (jokers.length > 0)
			{
				var firstCard:IMangoCard = cards[0];
				diff = firstCard.rank - 0; // diff from ace
				if (jokers.length <= diff)
					jokers.splice(0, diff);
			}
			
			// more jokers! adjust it in the last
			if (jokers.length > 0)
			{
				var lastCard:IMangoCard = cards[cards.length - 1];
				diff = 13 - lastCard.rank;
				if (jokers.length <= diff)
					jokers.splice(0, diff);
			}
			
			// more jokers!! you gotta be kidding me, not impure
			if (jokers.length > 0)
				return false;
			
			return true;
		}
		
		private static function isInSet(cards:Vector.<IMangoCard>, jokerRank:int):Boolean
		{
			if (cards.length < 3 || cards.length > 4)
				return false;
			
			cards = cards.slice();
			cards.sort(simpleSortBySuit);
			
			// first remove all the jokers
			var jokers:Vector.<IMangoCard> = gatherJokersInCards(cards, jokerRank);
			
			if (cards.length < 1)
				return false; // FIXME
			
			var card:IMangoCard = cards[0];
			var prevCard:IMangoCard = null;
			for (var i:int = 1; i < cards.length; i++)
			{
				prevCard = card;
				card = cards[i];
				
				if (prevCard.suit == card.suit)
					return false;
				
				if (prevCard.rank != card.rank)
					return false;
			}
			
			return true;
		}
		
		public static function isSorted(cards:Vector.<IMangoCard>, jokerRank:int):int
		{
			if (isPureSequence(cards))
				return SORTTYPE_PURE;
			
			if (isImpureSequence(cards, jokerRank))
				return SORTTYPE_IMPURE;
			
			if (isInSet(cards, jokerRank))
				return SORTTYPE_SET;
			
			return SORTTYPE_NONE;
		}
		
		private static function resetContainers():void
		{
			_pureSequences = new Vector.<Vector.<IMangoCard>>();
			_impureSequences = new Vector.<Vector.<IMangoCard>>();
			_sets = new Vector.<Vector.<IMangoCard>>();
			_unsortedCards = new Vector.<Vector.<IMangoCard>>();
		}
		
		private static function simpleSortByRank(card1:IMangoCard, card2:IMangoCard):Number
		{
			if (card1.rank > card2.rank) return 1;
			if (card1.rank <= card2.rank) return -1;
			return 0;
		}
		
		private static function simpleSortBySuit(card1:IMangoCard, card2:IMangoCard):Number
		{
			if (card1.suit > card2.suit) return 1;
			if (card1.suit <= card2.suit) return -1;
			return 0;
		}
		
		private static function mergeGroupIntoHandCards(sourceGroups:Vector.<Vector.<IMangoCard>>, handCards:Vector.<Vector.<IMangoCard>>):void
		{
			if (sourceGroups.length < 1)
				return;
			
			for (var i:int = 0; i < sourceGroups.length; i++)
			{
				var groupCard:Vector.<IMangoCard> = sourceGroups[i];
				if (groupCard.length > 0)
					handCards.push(groupCard);
			}
		}
		
		private static var _timeStamp:int = -1;
		public static function timeSnapShot(reset:Boolean = false):void
		{
			if (!TRACK_TIME)
				return;
			
			if (_timeStamp == -1 || reset)
			{
				_timeStamp = getTimer();
				trace ("<<<<< time stamp noted >>>>>");
			}
			else
			{
				_timeStamp = getTimer() - _timeStamp;
				trace (">>>>> total time taken: " + _timeStamp + " ms <<<<<");
				
				_timeStamp = -1;
			}
		}
	}
}
