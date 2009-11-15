require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "fileutils"
require "uuid"

describe Game do


  def fake_output(game_process_line)
    fake_output = <<-OUT
PID COMMAND
  1 /sbin/launchd
 10 /usr/libexec/kextd
 11 /usr/sbin/notifyd
 12 /usr/sbin/syslogd
#{game_process_line}55555 destroy_everything.rb'
    OUT
  end

  def game_process_lines
     %[13012 pty_fifo_adapter.rb '/opt/local/bin/nethack -u "#{@user.login}"'\n]
     %[13013 /opt/local/bin/nethack -u #{@user.login}\n]
  end

  before do
    @test_temp_dir = FileUtils.mkdir_p(File.join(Dir.tmpdir, "webhack_test_dir_#{UUID.generate}"))
    stub(Game).game_fifo_dir { @test_temp_dir }
    @user = Factory(:user)
    @game = Game.new(@user)
    @pretend_game_has_been_started = false;

    stub(Game).backtick("ps -eo pid,command") {
      if @pretend_game_has_been_started
        fake_output(game_process_lines)
      else
        fake_output("")
      end
    }

    stub(Game).daemonize(anything) do
      @pretend_game_has_been_started = true
    end

  end

  after do
    FileUtils.rm_rf(@test_temp_dir)
  end

  describe "#downward_fifo_name" do
    it "should generate an downward fifo name" do
      @game.downward_fifo_name.should == "#{@test_temp_dir}/downward_fifo_#{@user.id}"
    end
  end

  describe "#upward_fifo_name" do
    it "should generate an upward fifo name" do
      @game.upward_fifo_name.should == "#{@test_temp_dir}/upward_fifo_#{@user.id}"
    end
  end

  describe "#make_fifo" do
    it "should make a fifo" do
      fifo_path = File.join(@test_temp_dir, "i_am_a_fifo")
      Game.make_fifo(fifo_path)
      `ls -l #{fifo_path}`.should =~ /^p/
    end
  end

  describe "#make_fifos" do
    it "should make and upward and downward fifos" do
      @game.make_fifos
      `ls -l #{@game.downward_fifo_name}`.should =~ /^p/
      `ls -l #{@game.upward_fifo_name}`.should =~ /^p/
    end
  end

  describe "#unlink_fifos" do
    it "should unlink the upward and downward fifos" do
      @game.make_fifos
      @game.unlink_fifos

      File.exist?(@game.downward_fifo_name).should be_false
      File.exist?(@game.upward_fifo_name).should be_false
    end
  end

  describe "pid" do

    context "when the game is running" do
      before do
        @pretend_game_has_been_started = true
      end

      it "should return the pid of the game process" do
        @game.pid.should == 13013
      end
    end

    context "when the game not running" do
      before do
        @pretend_game_has_been_started = false
      end

      it "should return the pid of the game process" do
        @game.pid.should be_nil
      end
    end

  end

  describe "start" do
    context "when the game already is running" do
      before do
        @pretend_game_has_been_started = true
      end

      it "should not start a new game process" do
        dont_allow(Game).daemonize
        @game.start
      end
    end

    context "when the game not running" do
      before do
        @pretend_game_has_been_started = false
        @game.start
      end

      it "should start a new game process" do
        Game.should have_received.daemonize(%r[pty_fifo_adapter])
      end

    end
  end



end