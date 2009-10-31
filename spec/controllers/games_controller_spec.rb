require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../helpers/resource_spec_helper')
describe GamesController do

  it_should_behave_like "a restfully routed resource"

  describe "actions" do

    before do
      @resource_class = Game
      @resource = Factory(:game, :name =>"the game")
      @other_resource= Factory(:game, :name =>"the other game")
      @good_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game))
      @bad_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game, :pid => "Xorn"))
      @resource_count_before = Game.count
    end


    it_should_behave_like "a restfully indexed resource"
    it_should_behave_like "a restfully shown resource"
    it_should_behave_like "a restfully newed resource"
    it_should_behave_like "a restfully edited resource"
    it_should_behave_like "a restfully created resource"
    it_should_behave_like "a restfully updated resource"
    it_should_behave_like "a restfully destroyed resource"
    

  end
end