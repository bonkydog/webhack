require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Game do


  describe "schema" do

    it "should have a name  field" do
      should have_db_column(:name).of_type(:string).with_options(:null => false)
    end

    it "should have a pid field" do
      should have_db_column(:pid).of_type(:integer).with_options(:null => false)
    end

    it "should index the pid field" do
      should have_db_index(:pid).unique(true)
    end

    it_should_behave_like "a timestamped model"
    
  end


  describe "validations" do

    before do
      @game = Factory(:game)
    end

    it "is valid fresh from the factory" do
      @game.should be_valid
    end

    it "should require a name" do
      should validate_presence_of :name
    end

    it "should require a numeric pid" do
      should validate_numericality_of :pid
    end

    it "should require pid to be unique" do
      should validate_uniqueness_of :pid
    end

  end
end