require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe DungeonsController do

  describe "subresource routes" do

    it "should route to restful update" do
      should route(:put, "/game/dungeon").to(:controller => :dungeons, :action => :update)
    end

  end

  describe "actions" do
    before do
      @user = Factory(:user)
      @game = Game.new(@user)

      before do
        stub.proxy(Game).new do
          stub(@game).move(anything) {"OK, you're east."}
        end

      end

      describe "#update" do
        xhr :put, :update, :move => "go east"
      end

      it "should relay the move to the game" do
        @found_game.should have_received.move("go east")
      end

      it "should update the page via RJS" do
        response.should be_success
        response.should render_template(:update)
      end

    end

  end

end