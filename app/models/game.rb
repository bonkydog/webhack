class Game < ActiveRecord::Base

  include Multiplex

  #####################################################################
  # validations  

  validates_presence_of :name
  validates_numericality_of :pid
  validates_uniqueness_of :pid

  attr_protected :pid

  #####################################################################
  # fifo management

  DIRECTIONS = [:up, :down]

  def self.game_fifo_dir
    Dir.tmpdir
  end

  def self.make_fifo(fifo_path)
    `mkfifo #{fifo_path}`
  end

  def fifo_name(direction)
    raise ArgumentError unless DIRECTIONS.include?(direction)
    File.join("/tmp", "#{direction}ward")
#    File.join(Game.game_fifo_dir, "#{direction}ward_fifo_#{id}_#{pid}")
  end

  def make_fifos
    DIRECTIONS.each do |direction|
      Game.make_fifo(fifo_name(direction))
    end
  end

  def unlink_fifos
    DIRECTIONS.each do |direction|
      FileUtils.rm(fifo_name(direction))
    end
  end

  # SPIKE
  def start
    make_fifos

#    game = "/opt/local/bin/wumpus"
    game = "/opt/local/bin/nethack"
    adapter = File.join(Rails.root, "app/models/pty_fifo_adapter.rb")
    command = "#{adapter} #{game} #{fifo_name(:down)} #{fifo_name(:up)}"
    puts command
    self.pid = fork do
      exec "nohup #{command} &" # this is a crap way to do this.
    end
    sleep 0.5
  end


  # SPIKE
  def move(input)
    outgoing_buffer = input.bytes.to_a
    File.open(fifo_name(:down), File::WRONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |down|
      File.open(fifo_name(:up), File::RDONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |up|
        outgoing_buffer.each do |c|
          while !IO.select(nil, [down], nil, 3)
            puts "whuuut?"
          end
          down.syswrite(c.chr)
        end
      end
    end
  end

  def look
    buffer = ""

    File.open(fifo_name(:down), File::WRONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |down|
      File.open(fifo_name(:up), File::RDONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |up|
        while IO.select([up], nil, nil, 3)
          buffer += up.sysread(max_buffer_size)
        end
        buffer
      end
    end
  end


end
