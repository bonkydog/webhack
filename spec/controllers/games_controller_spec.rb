require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe GamesController do


  describe "routes" do

    it "should route to restful show" do
      should route(:get, "/game").to(:controller => :games, :action => :show)
    end

  end


  describe "authentication" do
    before do
      @game = Factory(:game)
    end

    it "should require authentication" do
      get :show, :id => @game
      response.should redirect_to "/"
    end
  end

  describe "actions" do
    before do
      @user = Factory(:user)
      @game = Factory(:game, :user => @user)
      login_as @user
    end

    describe "#show" do
      it "should fetch and assign the game for display" do
        get :show
        response.should be_success
        assigns(:game).should == @game
      end
    end


  end
end