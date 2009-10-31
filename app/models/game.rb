class Game < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :pid
  validates_uniqueness_of :pid

  DIRECTIONS = [:up, :down]

  def fifo_name(direction)
    raise ArgumentError unless DIRECTIONS.include?(direction)
    "/tmp/#{direction}ward_fifo_#{pid}"
  end
  
end
