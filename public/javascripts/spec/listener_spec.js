describe("listener", function () {

  var $ = jQuery;

  var listener = WEBHACK.listener();

  var event = function(which, shiftKey){
    which = Object.isString(which) ? which.charCodeAt() : which;
    var self = {};
    self.which = which;
    self.shiftKey = !!shiftKey;
    return self;
  };

  var ord = function(character){
    if (character.size() != 1)throw "ord expects a single character, but got '" + character + "' instead.";
    return character.charCodeAt();
  };

  describe("convertKeydownToCharacter", function () {
    it("should understand uppercase letters", function() {

      expect(listener.convertKeydownToCharacter(event("A", true))).toEqual("A");
      expect(listener.convertKeydownToCharacter(event("Z", true))).toEqual("Z");
    });
  });

  describe("convertKeydownToCharacter", function () {
    it("should understand lowercase letters", function() {
      expect(listener.convertKeydownToCharacter(event("A", false))).toEqual("a");
      expect(listener.convertKeydownToCharacter(event("Z", false))).toEqual("z");
    });
  });


});