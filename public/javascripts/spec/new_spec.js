describe('screen', function () {

  var $ = jQuery;
  var screen;
  beforeEach(function() {

    $("#scratch").remove();
    $("body").append($("<div>").attr("id", "scratch"));

    screen = WEBHACK.screen("#scratch");
  });



});