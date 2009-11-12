require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe GamesController do

  describe "routes" do
    it "should route to restful show" do
      should route(:get, "/game").to(:controller => :games, :action => :show)
    end
  end

  describe "authentication" do
    before do
      @user = Factory(:user)
      @game = Game.new(@user)
    end

    it "should require authentication" do
      get :show, :id => @game
      response.should redirect_to "/"
    end
  end

  describe "actions" do
    before do
      @user = Factory(:user)
      login_as @user
      stub.proxy(Game).new do |game|
        @game = game
        stub(@game).running? {true}
      end
    end

    describe "#show" do

      before do
        get :show
      end

      it "should succeed" do
        response.should be_success
      end

      it "should fetch and assign the game for display" do
        assigns(:game).should == @game
      end

    end
    describe "#show" do
      before do
        @controller.send(:flash)[:new_game] = nil
        stub(@controller).flash = {:new_game => nil}
        get :show
      end
      context "with an in-progress game" do
        it "should ask the listener to request a reload " do # otherwise, it's a blank screen.
          assigns[:reload].should be_true
        end
      end


      context "with a new game" do
        before do
          @controller.send(:flash)[:new_game] = true
          get :show
        end

        it "should not ask the listener to request a reload " do # because the opening dialogs don't like it.
          assigns[:reload].should be_false
        end
      end
    end


  end
end