describe('screen', function () {

  var $ = jQuery;
  var screen;
  beforeEach(function() {

    $("#scratch").remove();
    $("body").append($("<div>").attr("id", "scratch"));

    screen = WEBHACK.screen("#scratch");
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
          [
            [0,0],
            [0,5],
            [5,0],
            [5,81],
            [26,5],
            [26,80]
          ].each(function(coordinates) {
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

  describe("ANSI escape codes handling", function () {

    // Good ANSI escape code references:
    //
    // http://en.wikipedia.org/wiki/ANSI_escape_code
    // http://invisible-island.net/xterm/ctlseqs/ctlseqs.html

    var CSI = "\u001B]"; // ANSI Control Sequence Introducer

        describe("Cursor Position (CUP): CSI row ; col H", function () {
          it("should move the cursor to the requested position", function() {
            screen.print(CSI + "5;23H");
            expect(screen.getCursor().row).toEqual(5);
            expect(screen.getCursor().col).toEqual(23);
          });

          it("should not print characters", function() {
            screen.putCharacter("!", 5, 23);
            screen.setCursor(1, 1);
            screen.print("fox");
            screen.print(CSI + "5;23H");
            expect(screen.getCursor().row).toEqual(5);
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

        describe("Erase in Display (ED) CSI code K", function () {

          describe("Erase Below: CSI 0 J", function () {
            it("should clear the screen from the current through the bottom line (inclusive)", function() {
              $("table.screen td").html("x");
              screen.setCursor(12, 40);
              screen.print(CSI + "0J");
              expect($("table.screen tr:lt(11) td:contains(x)").size()).toEqual(11 * 80);
              expect($("table.screen tr:gt(10) td:contains(x)").size()).toEqual(0);
            });

            it("should alias to CSI J", function() {
              $("table.screen td").html("x");
              screen.setCursor(12, 40);
              screen.print(CSI + "J");
              expect($("table.screen tr:lt(11) td:contains(x)").size()).toEqual(11 * 80);
              expect($("table.screen tr:gt(10) td:contains(x)").size()).toEqual(0);
            });
          });

          describe("Erase Above: CSI 1 J", function () {
            it("should clear the screen from the current through the top line (inclusive)", function() {
              $("table.screen td").html("x");
              screen.setCursor(12, 40);
              screen.print(CSI + "1J");
              expect($("table.screen tr:lt(12) td:contains(x)").size()).toEqual(0);
              expect($("table.screen tr:gt(11) td:contains(x)").size()).toEqual((25 - 12) * 80);
            });
          });

          describe("Erase All: CSI 2 J", function () {
            it("should clear the screen", function() {
              $("table.screen td").html("x");
              screen.print(CSI + "2J");
              expect($("table.screen td:contains(x)").size()).toEqual(0);
            });
          });
        });


    describe("Erase in Line (EL), Erase to Right: CSI 0 K", function () {
      it("should clear line from the current column through the end (inclusive)", function() {
        $("table.screen td").html("x");
        screen.setCursor(12, 40);
        screen.print(CSI + "0K");
        expect($("table.screen tr:lt(11) td:contains(x)").size()).toEqual(11 * 80);
        expect($("table.screen tr:gt(11) td:contains(x)").size()).toEqual((25 - 12) * 80);
        expect($("table.screen tr:eq(11) td:lt(39):contains(x)").size()).toEqual(39);
        expect($("table.screen tr:eq(11) td:gt(38):contains(x)").size()).toEqual(0);
        expect(screen.getCharacter(12,40)).toEqual("");
        expect(screen.getCharacter(12,39)).toEqual("x");
        expect(screen.getCharacter(12,41)).toEqual("");
        expect(screen.getCharacter(11,40)).toEqual("x");
        expect(screen.getCharacter(13,41)).toEqual("x");
      });
    });


  });

});