WEBHACK.create_listener = function (uri){

  var $ = jQuery;

  var LOG = true;

  var uri = uri;
  var ready_to_send = true;
  var move_buffer = "";

  // private ####################################

  var convertKeypressToCharacter = function(event){
    var code = event.which;
    if (LOG) console.log("code=" + code);
    if (LOG) console.log("shift=" + event.shiftKey);
    if (LOG) console.log("control=" + event.ctrlKey);

    if ((code < 32 || code > 126 ) && code != 13 && code != 10) return "";

    if (!event.shiftKey) {
      if (code >= 65 && code <= 90) code = code + 32;
    }

    if (event.ctrlKey) {
      if (code >= 65 && code <= 90) code = code - 64;
      else if (code >= 97 && code <= 122) code = code - 96;
      else return "";
    }

    return String.fromCharCode(code);
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
      $.post(uri, { _method : 'PUT', move : move_buffer }, callback, 'script');
      ready_to_send = false;
      move_buffer = "";
      $().oneTime(10000, "webhack listener", timeout);
    }
  };

  var handleEvent = function(event){
    move(convertKeypressToCharacter(event));
  };

  var start = function(){
    $().bind("keydown", handleEvent);
  };

  var stop = function(){
    $().unbind("keydown", handleEvent);
  };

  // interface ##################################
  var self = {};

  self.convertKeypressToCharacter = convertKeypressToCharacter;
  self.move = move;
  self.start = start;
  self.stop = stop;

  return self;
};

