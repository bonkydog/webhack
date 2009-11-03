require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../helpers/resource_spec_helper')
describe DungeonsController do

  describe "subresource routes" do

    it "should route to restful edit" do
      should route(:get, "/games/1/dungeon/edit").to(:controller => :dungeons, :action => :edit, :game_id => 1)
    end

    it "should route to restful update" do
      should route(:put, "/games/1/dungeon").to(:controller => :dungeons, :action => :update, :game_id => 1)
    end

  end

  describe "actions" do
    before do
      @game = Factory(:game, :transcript => nil)
    end

    describe "#edit" do
      before do
        stub.proxy(Game).find do |game|
          stub(game).look {"fake output"}
        end
        get :edit, :game_id => @game.id
      end

      it "should fetch and assign the game for display" do
        assigns(:game).should == @game
      end

      it "should inspect and record game state" do
        @game.reload.transcript.should == "fake output"
      end
    end

    describe "#update" do
      before do
        stub.proxy(Game).find do |game|
          stub(@found_game = game).move(anything)
        end
        put :update, :game_id => @game.id, :move => "go east"
      end

      it "should relay the move to the game" do
        @found_game.should have_received.move("go east\n")
      end

      it "should redirect to edit" do
        response.should redirect_to(edit_game_dungeon_path(@game.id))
      end

    end

  end 

end