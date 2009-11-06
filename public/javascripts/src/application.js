var WEBHACK = {};

jQuery.noConflict();

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
    WEBHACK.s = WEBHACK.screen("div.screen-container");
    $().keydown(function(e) {
      var code = e.which;
      console.log("code=" + code);
      if ((code < 32 || code > 126) && code != 13 && code != 27){
        console.log("ignoring!");
        return;
      }
      if (e.ctrlKey && code >= 64 && code <= 95)
      {
        console.log("controlling!");
        code = code - 64;
      } else if (! e.shiftKey && (code >= 65 && code <= 93)) {
        console.log("shifting!");
        code = code + 32;
      }
      var c = String.fromCharCode(code);
      console.log("c=" + c);
      if (ok_to_send) {
        $.post("http://localhost:3000/games/1/dungeon", {"_method" : "PUT", "move" : buffer + c}, function(){
          ok_to_send = true;
          
        }, "script");
        buffer = ""
        ok_to_send = false;
      } else {
        buffer = buffer + c;
      }
      //}

    })
  }
  ;


});
