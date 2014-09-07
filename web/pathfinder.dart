import 'dart:html';
import 'dart:convert' show JSON;

List<BoonCard> WeaponDeck = new List<BoonCard>();
BoonCard cardPicked;


void main() {
  ButtonElement genButton = querySelector('#genButton');
  buildDeck("weapons.json");
  buildDeck("spells.json");
  buildDeck("allies.json");
  buildDeck("armour.json");
  buildDeck("blessings.json");
  buildDeck("loot.json");
  buildDeck("items.json");
}


void buildDeck(String fileName) {
  importFromJSON(fileName);
}


void importFromJSON (String fileName) {
    var path = fileName;
    HttpRequest.getString(path).then(createDeck);

}

void createDeck (String cardList) {
      List<Map> cards = JSON.decode(cardList); // import json into a list of Maps

      List<BoonCard> deck = new List<BoonCard>();  // create empty deck

      String deckType = cards[0]["type"]; // check the type of deck loaded from json

      for (int i = 1;  i < cards.length;  i++) {
        BoonCard card = new BoonCard(deckType, cards[i]["name"], cards[i]["set"],cards[i]["amount"]) ;
        deck.add(card);
        //print (card._cardName);
        //print("deck is long by "  + deck.length.toString());

      }


      // render decks to page
      loadDeck(deck);
}


// Render all cards on screen
void loadDeckOld(List<BoonCard> deck) {
  // get the type of deck by reading the type from the first card (all cards have same type in decks)
  String deckType = deck[0]._type;

  // Now target the appropriate div and table
  Element deckTable = querySelector('div#${deckType} table.deck-table');
  print('div#${deckType} table.deck-table');

  deck.forEach((card) {
      var tr = new TableRowElement();
       tr..setAttribute("class","card")
          ..setAttribute("data-name", "${card._cardName}")
           ..setAttribute("data-set", "${card._set}")
           ..setAttribute("data-amount", "${card._amount}");
        tr.children.addAll([
            new TableCellElement()..text = '${card._cardName}',
            new TableCellElement()..text = '${card._set}',
            new TableCellElement()..text = '${card._amount}']);
        deckTable.children.add(tr);
    });
    querySelector('div#${deckType} p.boon-type').text = deckType;
}


// Render all cards on screen
void loadDeck(List<BoonCard> deck) {
// get the type of deck by reading the type from the first card (all cards have same type in decks)
String deckType = deck[0]._type;

// Now target the appropriate div and table
Element deckTable = querySelector('div#${deckType} table.deck-table');

List<String> cardBuilder = [];
int deckSize = deck.length;
String cardText;
int counter = 0;

deck.forEach((card){
  counter++;
  cardText= "${card._cardName} (${card._set}) [x${card._amount}]";

  if ( cardBuilder.isEmpty && counter == deckSize)  {
    cardBuilder.add(cardText);
    cardBuilder.add("--");
  } else {
    cardBuilder.add(cardText);
  }

  if (cardBuilder.length == 2) {
     var tr = new TableRowElement();
        tr..setAttribute("class","card")
           ..setAttribute("data-name", "${card._cardName}")
            ..setAttribute("data-set", "${card._set}")
            ..setAttribute("data-amount", "${card._amount}");
         tr.children.addAll ( [
             new TableCellElement()..text = cardBuilder[0],
             new TableCellElement()..text = cardBuilder[1] ]);
         deckTable.children.add(tr);
         // clear list
         cardBuilder.clear();
   }

});
 querySelector('div#${deckType} p.boon-type').text = deckType;
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