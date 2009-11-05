WEBHACK.screen = function (spec, my){

  // private ####################################

  var self, cursor = {row: 1, column: 1};

  var build = function(container_selector) {
    var container = $(container_selector).slice(0,1);
    var table = $("<table>").addClass("screen");
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

  var getCursor = function (){
    return {row: cursor.row, column: cursor.column};
  };

  var setCursor = function(row, column){
    cursor.row = row;
    cursor.column = column;
  };


  my = my || {};

  // protected ##################################
  // (none yet -- add like this: my.foo = "blah";


  // interface ##################################
  self = {};

  self.build = build;
  self.getCursor = getCursor;
  self.setCursor = setCursor;

  return self;
};
