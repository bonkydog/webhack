describe('screen', function () {

  var $ = jQuery;
  var screen;
  beforeEach(function() {

    screen = WEBHACK.create_screen("body");
  });

  describe("construction", function () {

    it("should build a table", function() {
      expect($("table.screen").length).toEqual(1);
    });

    describe("the table", function () {
      it("should have 25 rows", function() {
        expect($("table.screen tr").length).toEqual(25);
      });
    });

    describe("the table", function () {
      it("should have 80 columns per row", function() {
        expect($("table.screen td").length).toEqual(25 * 80);
      });
    });
  });

  describe("basic terminal function", function () {

    describe("findCell", function () {
      it("should return a jQuery wrapped set containing the cell at the requested (ANSI) coordinates", function() {
        // Note: In ANSI escape codes, row 1, column 1 is the upper left corner of the screen.
        var foundCell = screen.findCell(17, 23);

        expect(foundCell.size()).toEqual(1);
        expect(foundCell.attr).toBeDefined(); // expecting jQuery-nature

        var expectedCell = $("table.screen tr:eq(16) td:eq(22)"); // jQuery selectors are zero-based.
        expect(foundCell[0]).toEqual(expectedCell[0]);
      });

      it("should throw an error when coordinates are out of bounds", function() {
        $.each([
          [0,0],
          [0,5],
          [5,0],
          [5,81],
          [26,5],
          [26,80]
        ], function() {
          var coordinates = this;
          var exception = undefined;
          try {
            screen.findCell(coordinates[0], coordinates[1]);
          } catch (e) {
            exception = e;
          }
          expect(exception).toBeDefined();
        })
      });

    });
    describe("getCursor", function () {
      it("should return the cursor coordinates", function() {
        expect(screen.getCursor()).toEqual({row:1, col: 1});
      });
    });

    describe("setCursor", function () {
      it("should move the cursor to the requested coordinates", function() {
        screen.setCursor(17, 23);
        expect(screen.getCursor()).toEqual({row:17, col: 23});
      });
      it("should understand numeric string coordinates", function() {
        screen.setCursor("3", "4");
        expect(screen.getCursor()).toEqual({row:3, col: 4});
      });

    });

    describe("putCharacter", function () {
      it("should should put a character into the cell at the requested coordinates", function() {
        screen.putCharacter("@", 12, 16); // ANSI escape is one-based.
        var cell = $("table.screen tr:eq(11) td:eq(15)"); // jQuery selectors are zero-based.
        expect(cell.html()).toEqual("@");
      });

      it("should not move the cursor", function() {
        var cursor_before = screen.getCursor();
        screen.putCharacter("^", 12, 16);
        expect(screen.getCursor().row).toEqual(cursor_before.row);
        expect(screen.getCursor().col).toEqual(cursor_before.col);
      });

      it("should escape demons", function() {
        screen.putCharacter("&", 12, 16);
        expect(screen.getCharacter(12, 16)).toEqual("&amp;")
      });

      it("should escape up-stairs", function() {
        screen.putCharacter("<", 12, 16);
        expect(screen.getCharacter(12, 16)).toEqual("&lt;")
      });

      it("should escape down-stairs", function() {
        screen.putCharacter(">", 12, 16);
        expect(screen.getCharacter(12, 16)).toEqual("&gt;")
      });

    });


    describe("getCharacter", function () {
      it("should get the character from the cell at the requested coordinates", function() {
        screen.putCharacter("*", 5, 19);
        expect(screen.getCharacter(5, 19)).toEqual("*");
      });

      it("should not move the cursor", function() {
        var cursor_before = screen.getCursor();
        screen.getCharacter(12, 16);
        expect(screen.getCursor().row).toEqual(cursor_before.row);
        expect(screen.getCursor().col).toEqual(cursor_before.col);
      });
    });

    describe("writeChraracter", function () {
      describe("when the argument is an ordinary character", function () {
        it("should put the character in the current cell (pointed to by the cursor)", function() {
          screen.setCursor(8, 7);
          screen.writeCharacter("d");
          expect(screen.getCharacter(8, 7)).toEqual("d");
        });

        describe("when the cursor is not on the right or bottom edge", function () {
          it("should move the cursor one column to the right", function() {
            screen.setCursor(9, 6);
            screen.writeCharacter("$");
            expect(screen.getCursor().row).toEqual(9);
            expect(screen.getCursor().col).toEqual(7);
          });
        });
        describe("when the cursor is on the right edge of the screen", function () {
          it("should move the cursor to the beginning of the next line", function() {
            screen.setCursor(9, 6);
            screen.writeCharacter("L");
            expect(screen.getCursor().row).toEqual(9);
            expect(screen.getCursor().col).toEqual(7);
          });
        });

        describe("when the cursor is on the bottom edge of the screen", function () {
          it("should move the cursor one column to the right", function() {
            screen.setCursor(9, 80);
            screen.writeCharacter("c");
            expect(screen.getCursor().row).toEqual(10);
            expect(screen.getCursor().col).toEqual(1);
          });
        });


        describe("when the cursor is in the bottom right corner of the screen", function () {
          it("should scroll everything up a row and move the cursor to the beginning of the new bottom row", function() {
            screen.putCharacter("1", 1, 1);
            screen.putCharacter("2", 2, 1);
            screen.putCharacter("X", 25, 1);
            screen.setCursor(25, 80);
            screen.writeCharacter("%");

            expect(screen.getCursor().row).toEqual(25);
            expect(screen.getCursor().col).toEqual(1);
            expect(screen.getCharacter(1, 1)).toEqual("2");
            expect(screen.getCharacter(2, 1)).toEqual("");
            expect(screen.getCharacter(24, 1)).toEqual("X");
            expect(screen.getCharacter(24, 80)).toEqual("%");

          });
        });

      });
    });

  });

  describe("print", function () {
    it("should write a string", function() {
      screen.setCursor(1, 1);
      screen.print("fox");
      expect(screen.getCharacter(1, 1)).toEqual("f");
      expect(screen.getCharacter(1, 2)).toEqual("o");
      expect(screen.getCharacter(1, 3)).toEqual("x");
    });
  });

  describe("addClass", function () {
    it("should add a class to the current cell", function() {
      screen.addClass("inverse", 1, 1);
      expect(screen.findCell(1, 1).hasClass("inverse")).toBeTruthy();
    });
  });

  describe("removeClass", function () {
    it("should add a class to the current cell", function() {
      screen.addClass("inverse", 1, 1);
      screen.removeClass("inverse", 1, 1);
      expect(screen.findCell(1, 1).hasClass("inverse")).toBeFalsy();
    });
  });


  describe("newline handling", function () {
    describe("line feed", function () {
      it("should move the cursor to the beginning of the next line", function() {
        screen.setCursor(2, 3);
        screen.print("\u000A");
        expect(screen.getCursor()).toEqual({row: 3, col: 1});
      });

      it("should scroll the lines up if on the last line", function() {
        screen.putCharacter("!", 1, 1);
        screen.putCharacter("?", 2, 1);
        screen.setCursor(25, 3);
        screen.print("\u000A");
        expect(screen.getCursor()).toEqual({row: 25, col: 1});
        expect(screen.getCharacter(1, 1)).toEqual("?");
        expect(screen.getCharacter(2, 1)).toEqual("");
      });
    });

    describe("carriage return", function () {
      it("should move the cursor to the beginning of the line", function() {
        screen.setCursor(1,10);
        screen.print("\u000D");
        expect(screen.getCursor()).toEqual({row:1, col:1});
      });
    });

  });

  describe("ANSI escape codes handling", function () {

    // Good ANSI escape code references:
    //
    // http://en.wikipedia.org/wiki/ANSI_escape_code
    // http://invisible-island.net/xterm/ctlseqs/ctlseqs.html

    var CSI = "\u001B["; // ANSI Control Sequence Introducer

    describe("ANSI escape codes handling", function () {

      var CSI = "\u001B["; // ANSI Control Sequence Introducer

      describe("Cursor Up (CUU): CSI n A", function () {
        it("should move the cursor n spaces up.", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "2A");
          expect(screen.getCursor()).toEqual({row: 10, col: 40});
        });

        it("should default 1 space up if n is missing", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "A");
          expect(screen.getCursor()).toEqual({row: 11, col: 40});
        });

        it("should default stop at the edge of the screen", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "14A");
          expect(screen.getCursor()).toEqual({row: 1, col: 40});
        });

      });


      describe("Cursor down (CUD): CSI n B", function () {
        it("should move the cursor n spaces down.", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "2B");
          expect(screen.getCursor()).toEqual({row: 14, col: 40});
        });

        it("should default 1 space down if n is missing", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "B");
          expect(screen.getCursor()).toEqual({row: 13, col: 40});
        });

        it("should default stop at the edge of the screen", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "14B");
          expect(screen.getCursor()).toEqual({row: 25, col: 40});
        });

      });

      describe("Cursor Back (CUB): CSI n D", function () {
        it("should move the cursor n spaces back.", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "2D");
          expect(screen.getCursor()).toEqual({row: 12, col: 38});
        });

        it("should default 1 space back if n is missing", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "D");
          expect(screen.getCursor()).toEqual({row: 12, col: 39});
        });

        it("should default stop at the edge of the screen", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "50D");
          expect(screen.getCursor()).toEqual({row: 12, col: 1});
        });

      });


      describe("Cursor forward (CUF): CSI n C", function () {
        it("should move the cursor n spaces forward.", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "2C");
          expect(screen.getCursor()).toEqual({row: 12, col: 42});
        });

        it("should default 1 space forward if n is missing", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "C");
          expect(screen.getCursor()).toEqual({row: 12, col: 41});
        });

        it("should default stop at the edge of the screen", function() {
          screen.setCursor(12, 40);
          screen.print(CSI + "50C");
          expect(screen.getCursor()).toEqual({row: 12, col: 80});
        });

      });


    });


    describe("Cursor Position (CUP): CSI row ; col H", function () {
      it("should move the cursor to the requested position", function() {
        screen.print(CSI + "5;23H");
        expect(screen.getCursor()).toEqual({row: 5, col: 23});
      });

      it("should default 1,1 if coordinates are missing", function() {
        screen.setCursor(10, 10);
        screen.print(CSI + "H");
        expect(screen.getCursor()).toEqual({row: 1, col: 1});
        expect(screen.getCursor().col).toEqual(1);
      });


      it("should not print characters", function() {
        screen.putCharacter("!", 5, 23);
        screen.setCursor(1, 1);
        screen.print("fox");
        screen.print(CSI + "5;23H");
        expect(screen.getCursor()).toEqual({row: 5, col: 23});
        expect(screen.getCursor().col).toEqual(23);
        expect(screen.getCharacter(1, 1)).toEqual("f");
        expect(screen.getCharacter(1, 2)).toEqual("o");
        expect(screen.getCharacter(1, 3)).toEqual("x");
        expect(screen.getCharacter(5, 23)).toEqual("!");
      });

      it("should return to non-escaped mode aftwerwards", function() {
        screen.print(CSI + "5;23H");
        screen.print("me");
        expect(screen.getCharacter(5, 23)).toEqual("m");
        expect(screen.getCharacter(5, 24)).toEqual("e");
      });
    });

    describe("Select Graphic Rendition (SGR) CSI mode m", function () {
      it("should add inverse class to all printed characters after mode is 7", function() {
        screen.setCursor(1, 1);
        screen.print(CSI + "7m");
        screen.print("me");
        expect(screen.findCell(1, 1).hasClass("inverse")).toBeTruthy();
        expect(screen.findCell(1, 2).hasClass("inverse")).toBeTruthy();
      });


      var test = function(message, mode) {
        it(message, function() {
          screen.setCursor(1, 1);
          screen.print(CSI + "7m");
          screen.print(CSI + mode + "m");
          screen.print("me");
          expect(screen.findCell(1, 1).hasClass("inverse")).toBeFalsy();
          expect(screen.findCell(1, 2).hasClass("inverse")).toBeFalsy();

        });

      };
      test("should stop adding inverse class after mode is set to 0", "0");
      test("should default to mode 0", "");

    });

    describe("erasure", function () {

      beforeEach(function() {
        $("table.screen td").html("x").addClass("inverse");
      });

      describe("Erase in Display (ED) CSI code J", function () {

        describe("Erase Below: CSI 0 J", function () {
          var test = function(message, code) {
            it(message, function() {
              screen.setCursor(12, 40);
              screen.print(code);
              expect($("table.screen tr:lt(11) td:contains(x)").size()).toEqual(11 * 80);
              expect($("table.screen tr:gt(10) td:contains(x)").size()).toEqual(0);
              expect($("table.screen tr:lt(11) td.inverse").size()).toEqual(11 * 80);
              expect($("table.screen tr:gt(10) td.inverse").size()).toEqual(0);
            });

          };

          test("should clear the screen from the current through the bottom line (inclusive)", CSI + "0J");
          test("should alias to CSI J", CSI + "J");
        });

        describe("Erase Above: CSI 1 J", function () {
          it("should clear the screen from the current through the top line (inclusive)", function() {
            screen.setCursor(12, 40);
            screen.print(CSI + "1J");
            expect($("table.screen tr:lt(12) td:contains(x)").size()).toEqual(0);
            expect($("table.screen tr:gt(11) td:contains(x)").size()).toEqual((25 - 12) * 80);
            expect($("table.screen tr:lt(12) td.inverse").size()).toEqual(0);
            expect($("table.screen tr:gt(11) td.inverse").size()).toEqual((25 - 12) * 80);
          });
        });

        describe("Erase All: CSI 2 J", function () {
          it("should clear the screen", function() {
            screen.print(CSI + "2J");
            expect($("table.screen td:contains(x)").size()).toEqual(0);
          });
        });
      });

      describe("Erase in Line (EL)", function () {

        describe("Erase to Right: CSI 0 K", function () {

          var test = function(message, code) {
            it(message, function() {
              screen.setCursor(12, 40);
              screen.print(code);
              expect($("table.screen tr:lt(11) td:contains(x)").size()).toEqual(11 * 80);
              expect($("table.screen tr:gt(11) td:contains(x)").size()).toEqual((25 - 12) * 80);
              expect($("table.screen tr:eq(11) td:lt(39):contains(x)").size()).toEqual(39);
              expect($("table.screen tr:eq(11) td:gt(38):contains(x)").size()).toEqual(0);
              expect($("table.screen tr:eq(11) td:lt(39).inverse").size()).toEqual(39);
              expect($("table.screen tr:eq(11) td:gt(38).inverse").size()).toEqual(0);
              expect(screen.getCharacter(12, 40)).toEqual("");
              expect(screen.getCharacter(12, 39)).toEqual("x");
              expect(screen.getCharacter(12, 41)).toEqual("");
              expect(screen.getCharacter(11, 40)).toEqual("x");
              expect(screen.getCharacter(13, 41)).toEqual("x");
            });
          };

          test("should clear line from the current column through the end (inclusive)", CSI + "0K");
          test("should alias to CSI K", CSI + "K");

        });


        describe("Erase to Left: CSI 1 K", function () {
          it("should clear line from the current column through the end (inclusive)", function() {
            screen.setCursor(12, 40);
            screen.print(CSI + "1K");
            expect($("table.screen tr:lt(11) td:contains(x)").size()).toEqual(11 * 80);
            expect($("table.screen tr:gt(11) td:contains(x)").size()).toEqual((25 - 12) * 80);
            expect($("table.screen tr:eq(11) td:lt(40):contains(x)").size()).toEqual(0);
            expect($("table.screen tr:eq(11) td:gt(39):contains(x)").size()).toEqual(80 - 40);
            expect($("table.screen tr:lt(11) td.inverse").size()).toEqual(11 * 80);
            expect($("table.screen tr:gt(11) td.inverse").size()).toEqual((25 - 12) * 80);
            expect($("table.screen tr:eq(11) td:lt(40)").filter(".inverse").size()).toEqual(0);
            expect($("table.screen tr:eq(11) td:gt(39)").filter(".inverse").size()).toEqual(80 - 40);
            expect(screen.getCharacter(12, 40)).toEqual("");
            expect(screen.getCharacter(12, 39)).toEqual("");
            expect(screen.getCharacter(12, 41)).toEqual("x");
            expect(screen.getCharacter(11, 40)).toEqual("x");
            expect(screen.getCharacter(13, 41)).toEqual("x");
          });
        });


        describe("Erase All: CSI 2 K", function () {
          it("should clear line from the current column through the end (inclusive)", function() {
            screen.setCursor(12, 40);
            screen.print(CSI + "2K");
            expect($("table.screen tr:lt(11) td:contains(x)").size()).toEqual(11 * 80);
            expect($("table.screen tr:gt(11) td:contains(x)").size()).toEqual((25 - 12) * 80);
            expect($("table.screen tr:eq(11) td:contains(x)").size()).toEqual(0);
            expect($("table.screen tr:lt(11) td").filter(".inverse").size()).toEqual(11 * 80);
            expect($("table.screen tr:gt(11) td").filter(".inverse").size()).toEqual((25 - 12) * 80);
            expect($("table.screen tr:eq(11) td").filter(".inverse").size()).toEqual(0);
            expect(screen.getCharacter(12, 40)).toEqual("");
            expect(screen.getCharacter(12, 39)).toEqual("");
            expect(screen.getCharacter(12, 41)).toEqual("");
            expect(screen.getCharacter(11, 40)).toEqual("x");
            expect(screen.getCharacter(13, 41)).toEqual("x");
          });
        });

      });
    });

    describe("backspace (ctrl-H, code 8)", function () {


      it("should move the cursor back one cell", function() {
        screen.setCursor(10, 20);
        screen.print("\u0008");
        expect(screen.getCursor()).toEqual({row: 10, col:19});
      });

      it("should should not delete anything", function() {
        screen.setCursor(10, 20);
        screen.print("abc");
        screen.setCursor(11, 20);
        screen.print("\u0008");
        expect(screen.getCharacter(10, 20)).toEqual("a");
        expect(screen.getCharacter(10, 21)).toEqual("b");
        expect(screen.getCharacter(10, 22)).toEqual("c");

      });

    });


    describe("unimplemented codes", function () {
      it("should ignore unimplemented codes and return to normal mode", function() {
        screen.putCharacter("a", 1, 1);
        screen.setCursor(1, 1);
        screen.print(CSI + "?25h"); // DEC specific: hide cursor.
        screen.print("z");
        expect(screen.getCharacter(1, 1)).toEqual("z");
      });
    });


  });

});