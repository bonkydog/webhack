require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe GamesController do


  describe "routes" do

    it "should route to restful show" do
      should route(:get, "/games/1").to(:controller => :games, :action => :show, :id => 1)
    end

    it "should route to restful new" do
      should route(:get, "/games/new").to(:controller => :games, :action => :new)
    end

    it "should route to restful create" do
      should route(:post, "/games").to(:controller => :games, :action => :create)
    end

    it "should route to restful update" do
      should route(:put, "/games/1").to(:controller => :games, :action => :update, :id => 1)
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
      login_as Factory(:user)


      @game = Factory(:game)
      @other_game= Factory(:game)
      @good_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game))
      @bad_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game, :name => ""))
      @game_count_before = Game.count
    end


    class Hash
      def without_automatic_fields
        copy = self.dup
        [:id, :created_at, :updated_at, :pid].each { |key| copy.delete(key); copy.delete(key.to_s) }
        copy
      end
    end


    describe "#show" do
      it "should fetch and assign the game for display" do
        get :show, :id => @game.id
        response.should be_success
        assigns(:game).should == @game
      end
    end

    describe "#new" do
      it "should create and assign a new game to fill in" do
        get :new
        response.should be_success
        assigns(:game).should be_a(Game)
        assigns(:game).should be_new_record
      end
    end

    describe "#create" do
      before do
        stub.proxy(Game).new do |game|
          stub(game).start do
            puts "pretending to start game..."
            game.pid = Factory.next(:pid)
          end
        end
      end

      context "with valid game" do
        before do
          post :create, :game => @good_attributes
        end

        it "should create a game" do
          Game.count.should == @game_count_before + 1
        end

        it "should redirect to show the new game" do
          response.should redirect_to(game_url(assigns[:game].id))
        end
      end

      context "with invalid game" do
        before do
          post :create, :game => @bad_attributes
        end

        it "should not create a game" do
          Game.count.should == @game_count_before
        end

        it "should assign game for correction" do
          assigns(:game).should be_a(Game)
          assigns(:game).should be_new_record
        end

        it "should render new" do
          response.should render_template(:new)
        end
      end

    end

  end
end