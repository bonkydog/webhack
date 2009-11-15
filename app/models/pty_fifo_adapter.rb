#!/usr/bin/env ruby

require "rubygems"
require "pty"
require "logger"
require "activesupport"
require "pp"
require File.join(File.dirname(__FILE__), "duplex_stream_adapter")


# first, set up the fifos:

# mkfifo /tmp/upward
# mkfifo /tmp/downward

# in the controller window, say:
# save_state=$(stty -g); stty raw; cat -u > /tmp/downward; stty "$save_state"

# in the view window, say:
# save_state=$(stty -g); stty raw; cat -u /tmp/upward; stty "$save_state"

# in the model window, say:
# script/game/fifo_pty_wrapper_spike.rb /opt/local/bin/wumpus  /tmp/downward /tmp/upward

# IO variables are named imagining the controlling process on top, this wrapper in the middle, and the
# controlled process on the bottom.

class PtyFifoAdapter

  cattr_accessor :logger
  self.logger = Logger.new(STDERR)
  self.logger.level = Logger::DEBUG
  # self.logger.level = Logger::INFO


  def initialize(command, downward_fifo_path, upward_fifo_path)
    @command = command
    @downward_fifo_path = downward_fifo_path
    @upward_fifo_path = upward_fifo_path
  end

  def run

    ENV["TERM"] = "xterm"
    ENV["SHELL"] = "/usr/bin/false"
    PTY.spawn(@command) do |coming_up, going_down|
      `mkfifo #{@downward_fifo_path}`
      `mkfifo #{@upward_fifo_path}`
      coming_down = File.open(@downward_fifo_path, File::RDONLY | File::EXCL | File::SYNC)
      going_up = File.open(@upward_fifo_path, File::WRONLY | File::EXCL | File::SYNC)

      DuplexStreamAdapter.new(coming_down, coming_up, going_down, going_up).adapt
    end
  rescue PTY::ChildExited
    logger.info("child exited.")
  ensure
    sleep 0.5 # give the controller a chance to pick up the last bit of output.
  end

end

if File.basename($0) == File.basename(__FILE__)
  unless ARGV.size == 3
    puts "usage: #$0 command downward_fifo_path upward_fifo_path"
    exit 1
  end

  PtyFifoAdapter.new(*ARGV).run
end