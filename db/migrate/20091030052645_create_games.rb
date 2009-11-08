class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :pid, :null => false
      t.timestamps :null => false
    end

    add_index :games, :pid, :unique => true

  end

  def self.down
    remove_index :games, :column => :pid
    drop_table :games
  end
end
