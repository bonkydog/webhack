WEBHACK.screen = function (container_selector, my){

  var $ = jQuery;

  // private ####################################

  var MIN_ROW = 1;
  var MIN_COL = 1;
  var MAX_ROW = 25;
  var MAX_COL = 80;

  var self;
  var cursor = {row: 1, col: 1};
  var container = $(container_selector).slice(0,1);
  var table;
  var tbody;
  var escapeBuffer = "";
  var escaping = false;

  var buildRow = function(tr){
    for (var row = 0; row < MAX_COL; ++row) {
      tr.append($("<td>"));
    }
  };

  var build = function() {
    tbody = $("<tbody>");
    table = $("<table>").addClass("screen");
    table.append(tbody);
    container.append(table);
    var col;
    for (col = 0; col < MAX_ROW; ++col) {
      var tr = $("<tr>");
      tbody.append(tr);
      buildRow(tr);
    }
  };

  build();

  var getCursor = function (){
    return {row: cursor.row, col: cursor.col};
  };

  var setCursor = function(row, col){
    cursor.row = row;
    cursor.col = col;
  };

  var findCell = function(row, col){
    if (row < MIN_ROW) throw "Row cannot be less than " + MIN_ROW + ". It was " + row + ".";
    if (col < MIN_COL) throw "Column cannot be less than " + MIN_COL + ". It was " + col + ".";
    if (row > MAX_ROW) throw "Row cannot greater than " + MAX_ROW + ". It was " + row + ".";
    if (col > MAX_COL) throw "Column cannot be greater than " + MAX_COL + ". It was " + col + ".";

    return tbody.children().slice(row - 1, row).children().slice(col - 1, col);
  };

  var putCharacter = function(character, row, col){
    findCell(row, col).html(character);
  };

  var getCharacter = function(row, col){
    return findCell(row, col).html();
  };

  var handleEscape = function(character) {
    var swallow_character = false;

    if (character == "\u001B") {
      escapeBuffer = "";
      escaping = true;
    }

    if (escaping) {
      swallow_character = true;
      escapeBuffer += character;
      var match = /^\u001B](\d{1,2});(\d{1,2})H/.exec(escapeBuffer);
      if (match) {
        var row = parseInt(match[1]);
        var col = parseInt(match[2]);
        setCursor(row, col);
        escaping = false;
      }
    }

    return swallow_character;
  };

  var writeCharacter = function(character){

    if (handleEscape(character)) return;

    putCharacter(character, cursor.row, cursor.col);
    cursor.col++;
    if (cursor.col > MAX_COL) {
      cursor.col = 1;
      cursor.row++;

      if (cursor.row > MAX_ROW) {
        cursor.row = MAX_ROW;
        var top_tr = tbody.children().slice(0,1);
        top_tr.remove();
        var tr = $("<tr>");
        buildRow(tr);
        tbody.append(tr);
      }
    }
  };

  var print = function(string){
    string.toArray().each(function(c){
      writeCharacter(c);
    });
  };

  my = my || {};

  // protected ##################################
  // (none yet -- add like this: my.foo = "blah";


  // interface ##################################
  self = {};

  self.build = build;
  self.findCell = findCell;
  self.getCursor = getCursor;
  self.setCursor = setCursor;
  self.putCharacter = putCharacter;
  self.getCharacter = getCharacter;
  self.writeCharacter = writeCharacter;
  self.print = print;
  
  return self;
};

