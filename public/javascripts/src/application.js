var WEBHACK = {};

jQuery.noConflict();

jQuery.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

jQuery.fn.submitWithAjax = function() {
  this.submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
  })
  return this;
};

jQuery(document).ready(function($) {
  $("form.ajax").submitWithAjax();
  $(".no-autocomplete").attr("autocomplete", "off");
  WEBHACK.screen("div.screen-container")
})


