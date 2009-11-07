describe('screen', function () {

  var $ = jQuery;
  var screen;
  beforeEach(function() {

    $("#scratch").remove();
    $("body").append($("<div>").attr("id", "scratch"));

    screen = WEBHACK.create_screen("#scratch");
  });

  var CSI = "\u001B["; // ANSI Control Sequence Introducer


});