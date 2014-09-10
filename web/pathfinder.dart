import 'dart:html';
import 'dart:convert' show JSON;

List<BoonCard> characterDeck = new List<BoonCard>();
int characterCardCount = 0;
ButtonElement saveDeck = querySelector('#save-deck');

void main() {
  if(characterCardCount == 0 )  saveDeck.classes.toggle("hide");
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
 // clear all headers and set this one to bold
 querySelectorAll('#deck-box p.boon-type').forEach((e) => e.setAttribute("class", "boon-type reset"));
 (e.target as ParagraphElement).setAttribute("class", "boon-type selected");

  String fileName = (e.target as ParagraphElement).attributes['id'].toString();
  fileName = fileName + '.json';
  // print (fileName);
  importFromJSON(fileName);
}

void buildWeaponDeck() {
  querySelector('#deck-box p.boon-type').setAttribute("class", "boon-type selected");
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
TableCellElement blank = new TableCellElement(); // blank cell

int deckSize = deck.length;
String cardText;
int counter = 0;

deck.forEach((card) {
   counter++;
   TableCellElement td = createTableCell(card);

   if ( cardBuilder.isEmpty && counter == deckSize)  {
      cardBuilder.add(td);
      cardBuilder.add(blank);
    } else {
      cardBuilder.add(td);
    }
  if (cardBuilder.length == 2) {
        cardBuilder[0].onClick.listen(addCardToCharacterDeck);
        cardBuilder[1].onClick.listen(addCardToCharacterDeck);
       var tr = new TableRowElement();
       tr.children.addAll ( [ cardBuilder[0], cardBuilder[1] ]);
        deckTable.children.add(tr);
        cardBuilder.clear();   // clear list
   }  // endif

}); // end foreach
 querySelector('div#${deckType} p.boon-type').text = deckType;
} // end loadDeck





void addCardToCharacterDeck (Event e) {
  String cardType = (e.target as TableCellElement).attributes['data-type'].toString();
  String cardName = (e.target as TableCellElement).attributes['data-name'].toString();
  String cardSet = (e.target as TableCellElement).attributes['data-set'].toString();
  BoonCard card = new BoonCard(cardType, cardName, cardSet, 1);
  characterDeck.add(card); // add card to character deck
  addCardToCharacterDeckTable(card); // add card to table

}

void addCardToCharacterDeckTable (BoonCard card) {

  TableElement characterDeckTable = querySelector(' table.character-deck-table'); // target the appropriate div and table
  TableCellElement td = createTableCellNameOnly(card); // create table cell
  td.classes.add( "card-in-deck");

  td.onClick.listen( (e) {
    characterDeck.remove(card); // remove card from deck
    td.classes.toggle("card-in-deck");
    td.classes.toggle("card-removed");
    td.children.add(new SpanElement()..text = " [undo]");
  });   //add listener to remove card from character deck

  characterCardCount++; // increment number of cards in player deck
  if(characterCardCount > 0 )  saveDeck.classes.remove("hide");

  if (characterCardCount.isOdd) {
    var tr = new TableRowElement();  // create new table row
    characterDeckTable.children.add(tr);
    tr.children.add (td);  // add table cell
    } else {
    // elseif card count even
    characterDeckTable.lastChild.append(td);  // select last table rowl
    }
}

//TODO https://www.dartlang.org/samples/#html5_persistence


/***********
 ** Helpers **
 ***********/

TableCellElement createTableCell (card) { // returns an html  <td> constructed from a card
  String cardText= "${card._cardName} (${card._set}) [x${card._amount}]";
  TableCellElement td = new TableCellElement();
   td..setAttribute("class","card")
        ..setAttribute("data-name", "${card._cardName}")
        ..setAttribute("data-set", "${card._set}")
        ..setAttribute("data-amount", "${card._amount}")
        ..text = cardText;
   return td;
}

TableCellElement createTableCellNameOnly (card) {  // as above but only writes the card name and set in the cell
  String cardText= "${card._cardName} (${card._set})";
  var td = new TableCellElement();
   td..setAttribute("class","card")
        ..setAttribute("data-name", "${card._cardName}")
        ..setAttribute("data-set", "${card._set}")
        ..setAttribute("data-amount", "${card._amount}")
        ..text = cardText;
   return td;
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

//MyObject o;
//o.the_argument = 1
//querySelector("elm").onClick.listen((event) => doShit(o.the_argument));
