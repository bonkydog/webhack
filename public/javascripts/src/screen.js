(function($) {

  jQuery.fn.buildScreen = function() {
    var table = $("<table>").addClass("screen");
    this.append(table);
    var y, x;
    for (y = 0; y < 25; ++y) {
      var row = $("<tr>");
      table.append(row);
      for (x = 0; x < 80; ++x) {
        row.append($("<td>"));
      }
    }
  };

})(jQuery);