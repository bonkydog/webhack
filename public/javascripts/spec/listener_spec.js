describe("listener", function () {

  var $ = jQuery;

  var listener;
  var event;
  beforeEach(function() {

    jasmine.Clock.useMock();

    listener = WEBHACK.create_listener("http://webhack.example.com:3000/games/1/dungeon");

    event = function(which, shiftKey, ctrlKey) {
      which = $.isString(which) ? which.charCodeAt() : which;
      var self = {};
      self.which = which;
      self.shiftKey = !!shiftKey;
      self.ctrlKey = !!ctrlKey;
      return self;
    };

  });



  describe("convertKeypressToCharacter", function () {
    it("should understand uppercase letters", function() {
      expect(listener.convertKeypressToCharacter(event("A", true))).toEqual("A");
      expect(listener.convertKeypressToCharacter(event("Z", true))).toEqual("Z");
    });

    it("should understand lowercase letters", function() {
      expect(listener.convertKeypressToCharacter(event("A", false))).toEqual("a");
      expect(listener.convertKeypressToCharacter(event("Z", false))).toEqual("z");
    });

    it("should understand carriage returns", function() {
      expect(listener.convertKeypressToCharacter(event("\r", false))).toEqual("\r");
    });

    it("should understand line feeds", function() {
      expect(listener.convertKeypressToCharacter(event("\n", false))).toEqual("\n");
    });

    it("should understand shifted number punctuations", function() {
      expect(listener.convertKeypressToCharacter(event("1", true))).toEqual("!");
      expect(listener.convertKeypressToCharacter(event("2", true))).toEqual("@");
      expect(listener.convertKeypressToCharacter(event("3", true))).toEqual("#");
      expect(listener.convertKeypressToCharacter(event("4", true))).toEqual("$");
      expect(listener.convertKeypressToCharacter(event("5", true))).toEqual("%");
      expect(listener.convertKeypressToCharacter(event("6", true))).toEqual("^");
      expect(listener.convertKeypressToCharacter(event("7", true))).toEqual("&");
      expect(listener.convertKeypressToCharacter(event("8", true))).toEqual("*");
      expect(listener.convertKeypressToCharacter(event("9", true))).toEqual("(");
      expect(listener.convertKeypressToCharacter(event("0", true))).toEqual(")");
    });

    it("should understand punctuation marks", function() {
      expect(listener.convertKeypressToCharacter(event("`", false))).toEqual("`");
      expect(listener.convertKeypressToCharacter(event("-", false))).toEqual("-");
      expect(listener.convertKeypressToCharacter(event("=", false))).toEqual("=");
      expect(listener.convertKeypressToCharacter(event("[", false))).toEqual("[");
      expect(listener.convertKeypressToCharacter(event("]", false))).toEqual("]");
      expect(listener.convertKeypressToCharacter(event(";", false))).toEqual(";");
      expect(listener.convertKeypressToCharacter(event(",", false))).toEqual(",");
      expect(listener.convertKeypressToCharacter(event(".", false))).toEqual(".");
      expect(listener.convertKeypressToCharacter(event("\\", false))).toEqual("\\");
      expect(listener.convertKeypressToCharacter(event(" ", false))).toEqual(" ");

    });

    it("should understand shifted punctuation marks", function() {
      expect(listener.convertKeypressToCharacter(event("`", true))).toEqual("~");
      expect(listener.convertKeypressToCharacter(event("-", true))).toEqual("_");
      expect(listener.convertKeypressToCharacter(event("=", true))).toEqual("+");
      expect(listener.convertKeypressToCharacter(event("[", true))).toEqual("{");
      expect(listener.convertKeypressToCharacter(event("]", true))).toEqual("}");
      expect(listener.convertKeypressToCharacter(event(";", true))).toEqual(":");
      expect(listener.convertKeypressToCharacter(event(",", true))).toEqual("<");
      expect(listener.convertKeypressToCharacter(event(".", true))).toEqual(">");
      expect(listener.convertKeypressToCharacter(event("\\", true))).toEqual("|");

    });

    

    it("should understand the control-letter keys", function() {
      expect(listener.convertKeypressToCharacter(event("A", false, true))).toEqual("\u0001");
      expect(listener.convertKeypressToCharacter(event("Z", false, true))).toEqual("\u001A");
      expect(listener.convertKeypressToCharacter(event("a", false, true))).toEqual("\u0001");
      expect(listener.convertKeypressToCharacter(event("z", false, true))).toEqual("\u001A");
    });

    it("should ignore weird codes", function() {
      expect(listener.convertKeypressToCharacter(event("\u0008", false))).toEqual("");
      expect(listener.convertKeypressToCharacter(event("\u007F", false))).toEqual("");

    });


    it("should ignore the control-nonletter keys", function() {
      expect(listener.convertKeypressToCharacter(event("!", false, true))).toEqual("");
    });
  });

  describe("move", function () {

    var args;
    var callback;
    beforeEach(function() {
      spyOn($, "post");
      listener.move("hjkl");
      expect($.post.callCount).toEqual(1);
      args = $.post.argsForCall[0];

    });

    afterEach(function() {
      $().stopTime("webhack listener");
    });

    it("should PUT a string to the uri", function() {
      expect(args[0]).toEqual("http://webhack.example.com:3000/games/1/dungeon");
      expect(args[1]).toEqual({"_method": "PUT", "move": "hjkl"});
      expect($.isFunction(args[2])).toBeTruthy();
      expect(args[3]).toEqual("script");
    });

    it("should buffer subsequent moves until its callback is triggered then send them.", function() {
      var callback = args[2];

      listener.move("qua");
      listener.move("ck");

      expect($.post.callCount).toEqual(1); // no second PUT yet.

      callback();

      expect($.post.callCount).toEqual(2); // now a PUT

      second_args = $.post.argsForCall[1];

      expect(second_args[0]).toEqual("http://webhack.example.com:3000/games/1/dungeon");
      expect(second_args[1]).toEqual({"_method": "PUT", "move": "quack"});
      expect(second_args[2]).toBe(callback);
      expect(second_args[3]).toEqual("script");
    });

    it("should send subsequent moves immediately, once it has received its callback", function() {
      var callback = args[2];

      callback();

      listener.move("quack");
      expect($.post.callCount).toEqual(2); // immediate second PUT
    });

    it("should try to send again after 10 seconds if there's no response", function() {

      var callback = args[2];


      expect($.post.callCount).toEqual(1); // no second PUT yet.

      listener.move("quack");

      jasmine.Clock.tick(10);

      expect($.post.callCount).toEqual(1); // still not yet
      jasmine.Clock.tick(10000);
      expect($.post.callCount).toEqual(2); // now a PUT
    });


    it("should should do nothing when called with an empty buffer and empty move", function() {
      expect($.post.callCount).toEqual(1);
      listener.move("");
      expect($.post.callCount).toEqual(1);
    });


  });


});