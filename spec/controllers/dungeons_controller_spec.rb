require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe DungeonsController do

  describe "subresource routes" do

    it "should route to restful update" do
      should route(:put, "/game/dungeon").to(:controller => :dungeons, :action => :update)
    end

  end

  describe "actions" do
    before do
      @game = Factory(:game)
    end

    describe "#update" do
      before do
        stub.proxy(Game).find do |game|
          stub(@found_game = game).move_and_look(anything) {"OK, you're east."}
        end
        xhr :put, :update, :game_id => @game.id, :move => "go east"
      end

      it "should relay the move to the game" do
        @found_game.should have_received.move_and_look("go east")
      end

      it "should update the page via RJS" do
        response.should be_success
        response.should render_template(:update)
      end

    end

  end

end