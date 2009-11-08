var WEBHACK = {};

jQuery(document).ready(function($) {

  $.ajaxSetup({
    'beforeSend': function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript")
    }
  });

  $(".focus").slice(0,1).focus();

  var buffer = "";
  var ok_to_send = true;

  if ($("div.screen-container").size() > 0) {
    WEBHACK.screen = WEBHACK.create_screen("div.screen-container");

    WEBHACK.listener = WEBHACK.create_listener("http://localhost:3000/game/dungeon");
    WEBHACK.listener.start();
    WEBHACK.listener.move("\u0012"); // control-R.  asks nethack to redraw the screen.
  }


});
