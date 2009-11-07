jQuery(function($){

  var logKeyEvent = function(event){
    var code = event.which;
    console.log("guess=" + String.fromCharCode(code));
    console.log("code=" + code);
    console.log("shift=" + event.shiftKey);
    console.log("control=" + event.ctrlKey);
    console.log("meta=" + event.metaKey);
    console.log("");
    return false;
    
  };
  $().keypress(logKeyEvent);
});