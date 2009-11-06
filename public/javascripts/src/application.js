var WEBHACK = {};

jQuery.noConflict();

jQuery(document).ready(function($) {

  $.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
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
  WEBHACK.s = WEBHACK.screen("div.screen-container");
});
