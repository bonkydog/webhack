class Game < ActiveRecord::Base

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
    File.join(Game.game_fifo_dir, "#{direction}ward_fifo_#{id}_#{pid}")
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



end
