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
      login_as @user
    end

    describe "#show" do

      context "when game is running" do
        before do
          stub.proxy(Game).new do
            stub(@game).look {"West of House"}
            stub(@game).running? {true}
          end
          xhr :get, :show
        end

        it "should succeed" do
          response.should be_success
        end

        it "should update the page via javascript" do
          response.should render_template("dungeons/show.js.haml")
        end

        it "should assign the output" do
          assigns[:output].should =~ /West of House/
        end
        
      end

# disabled pending session termination bugfix.      
#      context "when game is not running" do
#        before do
#          stub.proxy(Game).new do
#            dont_allow(@game).look
#            stub(@game).running? {false}
#          end
#          xhr :get, :show
#        end
#
#        it "should redirect to the home page" do
#          response.content_type.should == "text/javascript"
#          response.body.should == "location = '/';"
#        end
#      end
    end

    describe "#update" do

      context "when game is running" do

        before do
          stub.proxy(Game).new do
            stub(@game).move(anything) {"It is pitch dark.  You are likely to be eaten by a grue."}
            stub(@game).running? {true}
          end
          xhr :put, :update, :move => "go east"
        end

        it "should relay the move to the game" do
          @game.should have_received.move("go east")
        end

        it "should succeed" do
          response.should be_success
        end

        it "should update the page via javascript" do
          response.should render_template("dungeons/show.js.haml")
        end

        it "should assign the output" do
          assigns[:output].should =~ /It is pitch dark.  You are likely to be eaten by a grue./
        end


      end
# disabled pending session termination bugfix.      
#      context "when game is not running" do
#        before do
#          stub.proxy(Game).new do
#            dont_allow(@game).move(anything)
#            stub(@game).running? {false}
#          end
#          xhr :put, :update, :move => "go east"
#        end
#
#        it "should redirect to the home page via javacript" do
#          response.content_type.should == "text/javascript"
#          response.body.should == "location = '/';"
#        end
#
#      end


    end

  end
end