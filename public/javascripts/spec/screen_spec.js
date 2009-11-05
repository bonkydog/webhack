describe('screen', function () {

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


  describe("getCursor", function () {
    it("should return the cursor coordinates", function() {
      expect(screen.getCursor()).toEqual({row:1, column: 1});
    });
  });

  describe("setCursor", function () {
    it("should move the cursor to the requested coordinates", function() {
      screen.setCursor(17,23);
      expect(screen.getCursor()).toEqual({row:17, column: 23});
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
      expect(screen.getCursor().column).toEqual(cursor_before.column);
    });

    it("should escape demons", function() {
      var cursor_before = screen.getCursor();
      screen.putCharacter("&", 12, 16);
      expect(screen.getCharacter(12,16)).toEqual("&amp;")
    });

    it("should escape up-stairs", function() {
      var cursor_before = screen.getCursor();
      screen.putCharacter("<", 12, 16);
      expect(screen.getCharacter(12,16)).toEqual("&lt;")
    });

    it("should escape down-stairs", function() {
      var cursor_before = screen.getCursor();
      screen.putCharacter(">", 12, 16);
      expect(screen.getCharacter(12,16)).toEqual("&gt;")
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
      expect(screen.getCursor().column).toEqual(cursor_before.column);
    });


  });

  describe("writeChraracter", function () {
    describe("when the argument is an ordinary character", function () {
      it("should put the character in the current cell (pointed to by the cursor)", function() {
        screen.setCursor(8,7);
        screen.writeCharacter("d");
        expect(screen.getCharacter(8, 7)).toEqual("d");
      });

      describe("when the cursor is not on the right or bottom edge", function () {
        it("should move the cursor one column to the right", function() {
          screen.setCursor(9,6);
          screen.writeCharacter("$");
          expect(screen.getCursor().row).toEqual(9);
          expect(screen.getCursor().column).toEqual(7);
        });
      });
      describe("when the cursor is on the right edge of the screen", function () {
        it("should move the cursor to the beginning of the next line", function() {
          screen.setCursor(9,6);
          screen.writeCharacter("L");
          expect(screen.getCursor().row).toEqual(9);
          expect(screen.getCursor().column).toEqual(7);
        });
      });

      describe("when the cursor is on the bottom edge of the screen", function () {
        it("should move the cursor one column to the right", function() {
          screen.setCursor(9,80);
          screen.writeCharacter("c");
          expect(screen.getCursor().row).toEqual(10);
          expect(screen.getCursor().column).toEqual(1);
        });
      });


      describe("when the cursor is in the bottom right corner of the screen", function () {
        it("should scroll everything up a row and move the cursor to the beginning of the new bottom row", function() {
          screen.putCharacter("1", 1, 1);
          screen.putCharacter("2", 2, 1);
          screen.putCharacter("X", 25, 1);
          screen.setCursor(25,80);
          screen.writeCharacter("%");

          expect(screen.getCursor().row).toEqual(25);
          expect(screen.getCursor().column).toEqual(1);
          expect(screen.getCharacter(1,1)).toEqual("2");
          expect(screen.getCharacter(2,1)).toEqual("");
          expect(screen.getCharacter(24,1)).toEqual("X");
          expect(screen.getCharacter(24,80)).toEqual("%");

        });
      });

    });
  });
});