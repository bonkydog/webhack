require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe GamesController do

  it_should_behave_like "a restfully routed resource"

  class Hash
    def without_automatic_fields
      copy = self.dup
      [:id, :created_at, :updated_at].each { |key| copy.delete(key); copy.delete(key.to_s) }
      copy
    end
  end
  
  describe "actions" do

    before do
      @game = Factory(:game, :name =>"the game")
      @other_game= Factory(:game, :name =>"the other game")
      @good_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game))
      @bad_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game, :pid => "Xorn"))
      @game_count_before = Game.count
    end

    describe "#index" do
      it "should fetch and assign all games for listing" do
        get :index
        assigns(:games).should =~ [@game, @other_game]
      end
    end

    describe "#show" do
      it "should fetch and assign the game for display" do
        get :show, :id => @game.id
        assigns[:game].should == @game
      end
    end

    describe "#new" do
      it "should fetch and assign a new game to fill in" do
        get :new
        assigns(:game).should be_a(Game)
        assigns(:game).should be_new_record
      end
    end

    describe "#edit" do
      it "should fetch and assign the game to edit" do
        get :edit, :id => @game.id
        assigns(:game).should == @game
      end
    end

    describe "#create" do
      context "with valid game" do
        before do
          post :create, :game => @good_attributes
        end
        it "should create a game" do
          Game.count.should == @game_count_before + 1
        end

        it "should redirect to the games index" do
          response.should redirect_to(games_path)
        end

        it "should flash a notice" do
          flash[:notice].should_not be_nil
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

        it "should render edit" do
          response.should render_template(:new)
        end

      end
    end

    describe "#update" do
      context "with valid game" do
        before do
          put :update, :id => @game.id, :game => @good_attributes
        end

        it "should not update the record" do
          @game.reload.attributes.without_automatic_fields.should == @good_attributes
        end


        it "should redirect to the games index" do
          response.should redirect_to(games_path)
        end

        it "should flash a notice" do
          flash[:notice].should_not be_nil
        end
      end

      context "with invalid game" do
        before do
          put :update, :id => @game.id, :game => @bad_attributes
        end

        it "should not update the record" do
          @game.reload.attributes.without_automatic_fields.should_not == @bad_attributes
        end

        it "should assign game for correction" do
          assigns(:game).should == @game
        end

        it "should render edit" do
          response.should render_template(:edit)
        end
      end
    end

    describe "#destroy" do
      before do
        delete :destroy, :id => @game.id
      end

      it "should delete the game" do
        Game.find_by_id(@game.id).should be_nil
      end

      it "should redirect to to games index" do
        response.should redirect_to(games_path)
      end
    end
  end
end