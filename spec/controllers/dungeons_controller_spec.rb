require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../helpers/resource_spec_helper')
describe DungeonsController do

  describe "subresource routes" do

    it "should route to restful show" do
      should route(:get, "/games/1/dungeon").to(:controller => :dungeons, :action => :show, :game_id => 1)
    end

    it "should route to restful edit" do
      should route(:get, "/games/1/dungeon/edit").to(:controller => :dungeons, :action => :edit, :game_id => 1)
    end

    it "should route to restful update" do
      should route(:put, "/games/1/dungeon").to(:controller => :dungeons, :action => :update, :game_id => 1)
    end

  end

end