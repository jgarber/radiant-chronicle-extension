class AdjustYamlColumnType < ActiveRecord::Migration
  def self.up
    change_column :versions, :yaml, :text, :limit => 64.kilobytes + 1
  end

  def self.down
    change_column :versions, :yaml, :text
  end
end
