class Game < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :pid
  validates_uniqueness_of :pid
end
