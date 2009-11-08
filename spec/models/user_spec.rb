require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  describe "schema" do
    it "have a game" do
      should have_one(:game)
    end
  end
end