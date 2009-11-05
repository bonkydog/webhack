WEBHACK.screen = function (container_selector, my){

  // private ####################################

  var self;
  var cursor = {row: 1, column: 1};
  var container = $(container_selector).slice(0,1);
  var table;

  var build = function() {
    table = $("<table>").addClass("screen");
    container.append(table);
    var column, row;
    for (column = 0; column < 25; ++column) {
      var tr = $("<tr>");
      table.append(tr);
      for (row = 0; row < 80; ++row) {
        tr.append($("<td>"));
      }
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

  var putCharacter = function(character, row, column){
    var selector = "tr:eq(" + (row - 1) + ") td:eq(" + (column - 1) + ")";
    var cell = table.contents(selector).slice(0,1);
    cell.html(character);
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

  return self;
};

