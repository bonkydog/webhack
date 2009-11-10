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
  }



  $.log = function() {
    if (typeof console !== "undefined")
    {
      console.log.apply(this, arguments);
    }
  };
  
});
