class RemoveCalculatedDiff < ActiveRecord::Migration
  def self.up
    remove_column :versions, :diff
  end

  def self.down
    add_column :versions, :diff, :text
  end
end
