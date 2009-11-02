require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "fileutils"
require "uuid"

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
      @test_temp_dir = FileUtils.mkdir_p(File.join(Dir.tmpdir, "webhack_test_dir_#{UUID.generate}"))
      stub(Game).game_fifo_dir { @test_temp_dir }
      @game = Factory(:game)
      @game.id = 17
      @game.pid = 23
    end

    after do
      FileUtils.rm_rf(@test_temp_dir)
    end


    describe "#fifo_name" do
      it "should generate an downward fifo name" do
        @game.fifo_name(:down).should == "#{@test_temp_dir}/downward_fifo_17_23"
      end

      it "should generate an upward fifo name" do
        @game.fifo_name(:up).should == "#{@test_temp_dir}/upward_fifo_17_23"
      end

      it "should not generate bogus fifo names" do
        lambda { @game.fifo_name(:bed) }.should raise_error(ArgumentError)
      end
    end

    describe "#make_fifo" do
      it "should make a fifo" do
        fifo_path = File.join(@test_temp_dir, "i_is_a_fifo")
        Game.make_fifo(fifo_path)
        `ls -l #{fifo_path}`.should =~ /^p/
      end
    end

    describe "#make_fifos" do
      it "should make and upward and downward fifos" do
        @game.make_fifos
        `ls -l #{@game.fifo_name(:down)}`.should =~ /^p/
        `ls -l #{@game.fifo_name(:up)}`.should =~ /^p/
      end
    end


    describe "#unlink_fifos" do
      it "should unlink the upward and downward fifos" do
        @game.make_fifos
        @game.unlink_fifos

        File.exist?(@game.fifo_name(:down)).should be_false
        File.exist?(@game.fifo_name(:up)).should be_false
      end
    end

  end

end