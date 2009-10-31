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

    it "should be valid fresh from the factory" do
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

  describe "game handing" do
    before do
      @game = Factory(:game)
      @game.pid = 23
    end

    describe "#fifo_name" do

      it "should generate an downward fifo name" do
        @game.fifo_name(:down).should == "/tmp/downward_fifo_23"
      end

      it "should generate an upward fifo name" do
        @game.fifo_name(:up).should == "/tmp/upward_fifo_23"
      end

      it "should not generate bogus fifo names" do
        lambda { @game.fifo_name(:bed) }.should raise_error(ArgumentError)
      end
    end



  end
end