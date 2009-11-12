WEBHACK.create_screen = function (container_selector, options) {

  options = options || {};

  var $ = jQuery;

  // private ####################################

  var MIN_ROW = 1;
  var MIN_COL = 1;
  var MAX_ROW = 25;
  var MAX_COL = 80;

  var log_updates = options.log_updates;
  var log_rendering = options.log_rendering;
  var linefeed_handling = options.linefeed_handling;

  var cursor = {row: 1, col: 1};
  var container = $(container_selector).slice(0, 1);
  var table;
  var tbody;
  var escapeBuffer = "";
  var escaping = false;

  var sgr_mode = 0;

  var buildRow = function(tr) {
    for (var row = 0; row < MAX_COL; ++row) {
      tr.append($("<td>"));
    }
  };

  var build = function() {
    table = $("table.screen").slice(0, 1);
    if (table.size() > 0) {
      table.contents("td").erase();
      tbody = table.children("tbody");
    } else {
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
    }

  };

  var getCursor = function () {
    return {row: cursor.row, col: cursor.col};
  };

  var numerify = function(string_or_number) {
    if (string_or_number === "" || string_or_number === undefined) return 1; // lots of ANSI codes have arguments that default to 1 if missing.
    return $.isString(string_or_number) ? parseInt(string_or_number, 10) : string_or_number;
  };

  var setCursor = function(row, col) {
    cursor.row = numerify(row);
    cursor.col = numerify(col);
  };

  var findCell = function(row, col) {
    if (row < MIN_ROW) throw "Row cannot be less than " + MIN_ROW + ". It was " + row + ".";
    if (col < MIN_COL) throw "Column cannot be less than " + MIN_COL + ". It was " + col + ".";
    if (row > MAX_ROW) throw "Row cannot greater than " + MAX_ROW + ". It was " + row + ".";
    if (col > MAX_COL) throw "Column cannot be greater than " + MAX_COL + ". It was " + col + ".";

    var tr = tbody.children().slice(row - 1, row);
    var cell = tr.children().slice(col - 1, col);
    if (cell.size() != 1) throw "Couldn't find cell: " + row + "," + col;
    return cell;
  };

  var putCharacter = function(character, row, col) {
    findCell(row, col).text(character);
  };

  var getCharacter = function(row, col) {
    return findCell(row, col).html();
  };

  var wrapOrScrollIfNecessary = function() {
    if (cursor.col > MAX_COL) {
      cursor.col = 1;
      cursor.row++;
    }

    if (cursor.row > MAX_ROW) {
      cursor.row = MAX_ROW;
      var top_tr = tbody.children().slice(0, 1);
      top_tr.remove();
      var tr = $("<tr>");
      buildRow(tr);
      tbody.append(tr);
    }
  };


  var moveCursorUp = function(n) {
    cursor.row = Math.max(cursor.row - numerify(n), MIN_ROW)
  };
  var moveCursorDown = function(n) {
    cursor.row = Math.min(cursor.row + numerify(n), MAX_ROW)
  };
  var moveCursorBack = function(n) {
    cursor.col = Math.max(cursor.col - numerify(n), MIN_COL)
  };
  var moveCursorForward = function(n) {
    cursor.col = Math.min(cursor.col + numerify(n), MAX_COL)
  };

  var lineFeed = function() {
    if (linefeed_handling === "osx") {
      cursor.col = 1;
      cursor.row++;
      wrapOrScrollIfNecessary();
    } else {
      cursor.col = 1
    }

  };

  jQuery.fn.erase = function() {
    this.html("").removeAttr("class");
  };

  var ESCAPE_SEQUENCES = [

    //Cursor Position
    [/^\u001B\[(\d{1,2});(\d{1,2})H/, setCursor],

    //Cursor Position: default to 1,1
    [/^\u001B\[H/, function() {
      setCursor(1, 1)
    }],

    //Cursor Up
    [/^\u001B\[(\d*)A/, moveCursorUp],

    //Cursor Down
    [/^\u001B\[(\d*)B/, moveCursorDown],

    //Cursor Back
    [/^\u001B\[(\d*)D/, moveCursorBack],

    //Cursor Forward
    [/^\u001B\[(\d*)C/, moveCursorForward],

    //Backspace (move character back, don't delete anything)
    [/^\u0008/, moveCursorBack],

    // Erase in Display: Erase Below
    [/^\u001B\[0?J/, function() {
      $("table.screen tr:eq(" + (cursor.row - 1) + ") td").erase();
      $("table.screen tr:gt(" + (cursor.row - 1) + ") td").erase();
    }],

    // Erase in Display: Erase Above
    [/^\u001B\[1J/, function() {
      $("table.screen tr:lt(" + cursor.row + ") td").erase()
    }],

    // Erase in Display: Erase All
    [/^\u001B\[2J/, function() {
      $("table.screen td").erase()
    }],

    // Erase in Line: Erase to Right
    [/^\u001B\[0?K/, function() {
      $("table.screen tr:eq(" + (cursor.row - 1) + ") td:eq(" + (cursor.col - 1) + ")").erase();
      $("table.screen tr:eq(" + (cursor.row - 1) + ") td:gt(" + (cursor.col - 1) + ")").erase();
    }],

    // Erase in Line: Erase to Left
    [/^\u001B\[1K/, function() {
      $("table.screen tr:eq(" + (cursor.row - 1) + ") td:lt(" + cursor.col + ")").erase()
    }],

    // Erase in Line: Erase All
    [/^\u001B\[2K/, function() {
      $("table.screen tr:eq(" + (cursor.row - 1) + ") td").erase()
    }],

    // Set Graphic Rendition: inverse
    [/^\u001B\[7m/, function() {
      sgr_mode = 7
    }],

    // Set Graphic Rendition: normal
    [/^\u001B\[0?m/, function() {
      sgr_mode = 0
    }],

    // Line Feed
    [/^(\u000A)/, lineFeed],

    // Carriage Return
    [/^(\u000D)/, function() {
      cursor.col = 1
    }],

    // Unimplemented sequence: log and ignore.
    [/^(\u001B\[\??\d*;?\d*[a-zA-Z@`])/, function(x) {
      debug.log("Unimplemented ANSI escape sequence: " + x)
    }]
  ];

  var handleEscape = function(character) {
    var swallow_character = false;

    if (character === "\u001B" || character === "\u0008" || character === "\u000A" || character === "\u000D") {
      escapeBuffer = "";
      escaping = true;
    }

    if (escaping) {
      if (log_rendering) debug.log("escaped character: '", character + "' (" + character.charCodeAt(0) + ")");
      swallow_character = true;
      escapeBuffer += character;
      $.each(ESCAPE_SEQUENCES, function() {
        var mapping = this;
        if (!escaping) return;
        var regex = mapping[0];
        var method = mapping[1];
        var match = regex.exec(escapeBuffer);
        if (match) {
          var captured_groups = $.makeArray(match).slice(1);
          method.apply(null, captured_groups);
          escaping = false;
        }
      });
    }

    return swallow_character;
  };

  var writeCharacter = function(character) {

    if (handleEscape(character)) return;
    if (log_rendering) debug.log("rendered character: '", character + "' (" + character.charCodeAt(0) + ")");

    putCharacter(character, cursor.row, cursor.col);

    if (sgr_mode === 7) addClass("inverse", cursor.row, cursor.col);
    if (sgr_mode === 0) removeClass("inverse", cursor.row, cursor.col);

    cursor.col++;
    wrapOrScrollIfNecessary();
  };

  var print = function(string) {
    if (log_updates) debug.log(string);
    $.each($.makeArray(string.split('')), function(i, c) {
      writeCharacter(c);
    });
  };

  var addClass = function(css_class, row, col) {
    findCell(row, col).addClass(css_class);
  };

  var removeClass = function(css_class, row, col) {
    findCell(row, col).removeClass(css_class);
  };

  build();

  // interface ##################################

  var self = {};

  self.build = build;
  self.findCell = findCell;
  self.getCursor = getCursor;
  self.setCursor = setCursor;
  self.putCharacter = putCharacter;
  self.getCharacter = getCharacter;
  self.writeCharacter = writeCharacter;
  self.print = print;
  self.addClass = addClass;
  self.removeClass = removeClass;
  self.log_rendering = function(x) {
    log_rendering = x
  };
  self.log_updates = function(x) {
    log_updates = x
  };
  self.linefeed_handling = function(x) {
    linefeed_handling = x
  };

  return self;
};

