
describe('screen.js', function () {

  describe("#buildScreen", function () {

    beforeEach(function() {
      $("#scratch").remove();
      $("body").append($("<div>").attr("id", "scratch"))

      $("#scratch").buildScreen();
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
});