WEBHACK.listener = function (){

  var $ = jQuery;

  // private ####################################

  var interpretKeydownEvent = function(event){
    var code = event.which;
    if (!event.shiftKey) {
      code = code + 32;
    }
    return String.fromCharCode(code);
  };


  // interface ##################################
  var self = {};

  self.convertKeydownToCharacter = interpretKeydownEvent;

  return self;
};

