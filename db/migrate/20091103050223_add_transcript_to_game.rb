class AddTranscriptToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :transcript, :text
  end

  def self.down
    remove_column :games, :transcript
  end
end
