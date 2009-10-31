require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../helpers/resource_spec_helper')
describe GamesController do

  it_should_behave_like "a restfully routed resource"

  describe "actions" do
    before do
      @resource_class = Game
      @resource = Factory(:game)
      @other_resource= Factory(:game)
      @good_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game))
      @bad_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game, :pid => "Xorn"))
      @resource_count_before = Game.count
    end

    it_should_behave_like "a restfully controlled resource"

  end
end