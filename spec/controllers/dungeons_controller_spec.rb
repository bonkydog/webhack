require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../helpers/resource_spec_helper')
describe DungeonsController do

  describe "subresource routes" do

    it "should route to restful update" do
      should route(:put, "/games/1/dungeon").to(:controller => :dungeons, :action => :update, :game_id => 1)
    end

  end

  describe "actions" do
    before do
      @game = Factory(:game, :transcript => nil)
    end

    describe "#update" do
      before do
        stub.proxy(Game).find do |game|
          stub(@found_game = game).move_and_look(anything) {"OK, you're east."}
        end
        put :update, :game_id => @game.id, :move => "go east"
      end

      it "should relay the move to the game" do
        @found_game.should have_received.move_and_look("go east\n")
      end

      it "should update the page via RJS" do
        response.should be_success
        response.body.should == <<-JS.unindented
          Element.insert("transcript", { bottom: "OK, you're east." });
          new Effect.ScrollTo("move",{});
        JS

      end

    end

  end

end