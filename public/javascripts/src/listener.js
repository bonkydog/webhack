WEBHACK.create_listener = function (uri){

  var $ = jQuery;

  var LOG_CODES = false;

  var ready_to_send = true;
  var move_buffer = "";

  // private ####################################

  var convertKeypressToCharacter = function(event){
    var code = event.which;
    if (LOG_CODES) console.log("code=" + code);
    if (LOG_CODES) console.log("shift=" + event.shiftKey);
    if (LOG_CODES) console.log("control=" + event.ctrlKey);
    if (LOG_CODES) console.log("meta=" + event.metaKey);

    if (event.metaKey) return "";

    if ((code < 32 || code > 126 ) && code != 13 && code != 10) return "";

    if (!event.shiftKey) {
      if (code >= 65 && code <= 90) code = code + 32;
    }
    if (event.ctrlKey) {
      if (code >= 65 && code <= 90) code = code - 64;
      else if (code >= 97 && code <= 122) code = code - 96;
      else return "";
    }

    var character = String.fromCharCode(code);

    if (event.shiftKey) {
      switch (character) {
        case "1" : return "!";
        case "2" : return "@";
        case "3" : return "#";
        case "4" : return "$";
        case "5" : return "%";
        case "6" : return "^";
        case "7" : return "&";
        case "8" : return "*";
        case "9" : return "(";
        case "0" : return ")";
        case "`" : return "~";
        case "-" : return "_";
        case "=" : return "+";
        case "[" : return "{";
        case "]" : return "}";
        case ";" : return ":";
        case "," : return "<";
        case "." : return ">";
        case "/" : return "?";
        case "\\" : return "|";
      }
    }
    return character;
  };

  var callback = function(){
    ready_to_send = true;
    move("");
  };


  var timeout = function(){
    console.error("timed out waiting for response");
    callback();
  };


  var move = function(move){
    move_buffer += move;
    if (move_buffer === "") return; 
    if (ready_to_send) {
      $().stopTime("webhack listener");
      $.post(uri, { _method : 'PUT', move : move_buffer, authenticity_token: $('#authenticity_token').val()}, callback, 'script');
      ready_to_send = false;
      move_buffer = "";
      $().oneTime(10000, "webhack listener", timeout);
    }
  };

  var handleEvent = function(event){
    var character = convertKeypressToCharacter(event);
    if (character === "") return true;
    move(character);
    return false;
  };



  var start = function(){
    $().bind("keypress", handleEvent);
  };

  var stop = function(){
    $().unbind("keypress", handleEvent);
  };

  // interface ##################################
  var self = {};

  self.convertKeypressToCharacter = convertKeypressToCharacter;
  self.move = move;
  self.start = start;
  self.stop = stop;

  return self;
};

