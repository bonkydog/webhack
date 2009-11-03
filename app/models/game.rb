class Game < ActiveRecord::Base

  include Multiplex

  #####################################################################
  # validations  

  validates_presence_of :name
  validates_numericality_of :pid
  validates_uniqueness_of :pid

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

  def start
    make_fifos

    game = "/opt/local/bin/wumpus"
    adapter = File.join(Rails.root, "app/models/pty_fifo_adapter.rb")
    command = "#{adapter} #{game} #{fifo_name(:down)} #{fifo_name(:up)}"
    puts command
    system "nohup #{command} &"
  end

  def read
    buffer = []
    down = File.open(fifo_name(:down), File::WRONLY | File::EXCL | File::SYNC)
    up = File.open(fifo_name(:up), File::RDONLY | File::EXCL | File::SYNC)
    select_readable([up])
    read_if_ready(up, buffer)
    buffer
  end

end
