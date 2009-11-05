WEBHACK.screen = function (container_selector, my){

  // private ####################################

  var self;
  var cursor = {row: 1, column: 1};
  var container = $(container_selector).slice(0,1);
  var table;
  var tbody;

  var buildRow = function(tr){
    for (row = 0; row < 80; ++row) {
      tr.append($("<td>"));
    }
  };

  var build = function() {
    tbody = $("<tbody>");
    table = $("<table>").addClass("screen");
    table.append(tbody);
    container.append(table);
    var column, row;
    for (column = 0; column < 25; ++column) {
      var tr = $("<tr>");
      tbody.append(tr);
      buildRow(tr);
    }
  };

  build();

  var getCursor = function (){
    return {row: cursor.row, column: cursor.column};
  };

  var setCursor = function(row, column){
    cursor.row = row;
    cursor.column = column;
  };

  var findCell = function(row, column){
    return tbody.children().slice(row - 1, row).children().slice(column - 1, column);
  };

  var putCharacter = function(character, row, column){
    findCell(row, column).html(character);
  };

  var getCharacter = function(row, column){
    return findCell(row, column).html();
  };

  var writeCharacter = function(character){
    putCharacter(character, cursor.row, cursor.column);
    cursor.column++;
    if (cursor.column > 80) {
      cursor.column = 1;
      cursor.row++;

      if (cursor.row > 25) {
        cursor.row = 25;
        var top_tr = tbody.children().slice(0,1);
        top_tr.remove();
        var tr = $("<tr>")
        buildRow(tr);
        tbody.append(tr);
      }
    }
  };


  my = my || {};

  // protected ##################################
  // (none yet -- add like this: my.foo = "blah";


  // interface ##################################
  self = {};

  self.build = build;
  self.getCursor = getCursor;
  self.setCursor = setCursor;
  self.putCharacter = putCharacter;
  self.getCharacter = getCharacter;
  self.writeCharacter = writeCharacter;
  
  return self;
};

