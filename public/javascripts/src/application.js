var WEBHACK = {};

jQuery(document).ready(function($) {

  $.ajaxSetup({
    'beforeSend': function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript")
    }
  });

  $.fn.submitWithAjax = function() {
    this.submit(function() {
      $.post(this.action, $(this).serialize(), null, "script");
      return false;
    });
    return this;
  };


  $("form.ajax").submitWithAjax();
  $(".no-autocomplete").attr("autocomplete", "off");



  var buffer = "";
  var ok_to_send = true;

  if ($("div.screen-container").size() > 0) {
    WEBHACK.screen = WEBHACK.create_screen("div.screen-container");

    WEBHACK.listener = WEBHACK.create_listener("http://localhost:3000/games/4/dungeon");
    WEBHACK.listener.start();
    WEBHACK.listener.move("\u0012"); // control-R.  asks nethack to redraw the screen.
  }


});
