import 'dart:html';
import 'dart:convert' show JSON;

List<BoonCard> WeaponDeck = new List<BoonCard>();
BoonCard cardPicked;


void main() {
  ButtonElement genButton = querySelector('#genButton');
  buildWeaponDeck();
  querySelector('#weapons').onClick.listen(buildDeck);
  querySelector('#armour').onClick.listen(buildDeck);
  querySelector('#allies').onClick.listen(buildDeck);
  querySelector('#items').onClick.listen(buildDeck);
  querySelector('#spells').onClick.listen(buildDeck);
  querySelector('#loot').onClick.listen(buildDeck);
  querySelector('#blessings').onClick.listen(buildDeck);

}

void buildDeck(Event e) {
  String fileName = (e.target as ParagraphElement).attributes['id'].toString();
  fileName = fileName + '.json';
  // print (fileName);
  importFromJSON(fileName);
}

void buildWeaponDeck() {
  importFromJSON("weapons.json");
}

void importFromJSON (String fileName) {
    var path = fileName;
    HttpRequest.getString(path).then(generateDeck);

}

void generateDeck (String cardList) {
      List<Map> cards = JSON.decode(cardList); // import json into a list of Maps
      List<BoonCard> deck = new List<BoonCard>();  // create empty deck
      String deckType = cards[0]["type"]; // check the type of deck loaded from json

      for (int i = 1;  i < cards.length;  i++) {
        BoonCard card = new BoonCard(deckType, cards[i]["name"], cards[i]["set"],cards[i]["amount"]) ;
        deck.add(card);
      }
      loadDeck(deck);       // render decks to page
}


// Render deck on screen
void loadDeck(List<BoonCard> deck) {
String deckType = deck[0]._type; // get the type of deck by reading the type from the first card (all cards have same type in decks)
TableElement deckTable = querySelector(' table.deck-table'); // Now target the appropriate div and table
deckTable.children.clear(); // clear previous table
List<TableCellElement> cardBuilder = [];
TableCellElement blank = new TableCellElement()..text = ""; // blank cell

int deckSize = deck.length;
String cardText;
int counter = 0;

deck.forEach((card) {
  counter++;
  cardText= "${card._cardName} (${card._set}) [x${card._amount}]";
  var td = new TableCellElement();
   td..setAttribute("class","card")
        ..setAttribute("data-name", "${card._cardName}")
        ..setAttribute("data-set", "${card._set}")
        ..setAttribute("data-amount", "${card._amount}")
        ..text = cardText;

  //  print ('${td.attributes.keys} : ${td.attributes.values}');

   if ( cardBuilder.isEmpty && counter == deckSize)  {
      cardBuilder.add(td);
      cardBuilder.add(blank);
    } else {
      cardBuilder.add(td);
    }
  if (cardBuilder.length == 2) {
        cardBuilder[0].onClick.listen(pickCard);
        cardBuilder[1].onClick.listen(pickCard);
       var tr = new TableRowElement();
       tr.children.addAll ( [ cardBuilder[0], cardBuilder[1] ]);
        deckTable.children.add(tr);
        cardBuilder.clear();   // clear list
   }  // endif

}); // end foreach
 querySelector('div#${deckType} p.boon-type').text = deckType;
} // end loadDeck

void pickCard (Event e) {
  String cardName = (e.target as TableCellElement).attributes['data-name'].toString();
  Element card = new DivElement()..text = cardName;
  card.setAttribute("class",  "card-in-deck");
  card.onClick.listen(removeCardFromDeck);
  querySelector('#character-deck').children.add(card);
}

void removeCardFromDeck(Event e) {
  querySelector('#character-deck').children.remove(e.target);

}

/***********
 ** Classes **
 ***********/

class BoonCard {
  String _type; // category of card, e.g. weapon
  String _cardName;   // name of the card
  String _set;   // adventure deck the card belongs to
  int _amount; // max number o cards of this type

  BoonCard (String type, String name, String set, int qty) {
    this._type = type;
    this._cardName = name;
    this._set = set;
    this._amount = qty;
  }

 BoonCard.fromJSON(String jsonString) {
    Map storedCard = JSON.decode(jsonString);
    _type = storedCard['type'];
    _cardName = storedCard['name'];
    _set = storedCard['set'];
    _amount = storedCard['amount'];

  }
}