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
      screen.putCharacter("@", 12, 16); // ansi is one-based.
      var cell = $("table.screen tr:eq(11) td:eq(15)"); // jquery selectors are zero-based.
      expect(cell.html()).toEqual("@");
    });
  });

  describe("get", function () {
    it("should get the character from the cell at the requested coordinates", function() {
      
    });
  });

  describe("writeChraracter", function () {
    describe("when the argument is an ordinary character", function () {
      it("should put the character in the current cell (pointed to by the cursor)", function() {

      });

      describe("when the cursor is not on the right or bottom edge", function () {
        it("should move the cursor one column to the right", function() {

        });
      });
      describe("when the cursor is on the right edge of the screen", function () {
        it("should move the cursor to the beginning of the next line", function() {

        });
      });
      describe("when the cursor is on the bottom edge of the screen", function () {
        it("should move the cursor one column to the right", function() {

        });
      });
      describe("when the cursor is in the bottom right corner of the screen", function () {
        it("should scroll everything up a row and move the cursor to the beginning of the new bottom row", function() {

        });
      });

    });
  });
});