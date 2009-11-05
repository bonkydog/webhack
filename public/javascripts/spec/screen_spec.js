describe('screen', function () {

  var screen;
  beforeEach(function() {
    screen = WEBHACK.screen();
  });

  describe("#buildScreen", function () {

    beforeEach(function() {
      $("#scratch").remove();
      $("body").append($("<div>").attr("id", "scratch"))

      screen.build("#scratch");
    });

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

    });
  });

  describe("writeToScreen", function () {
    describe("when the argument is an ordinary character", function () {
      it("should write the character into the current cell", function() {

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