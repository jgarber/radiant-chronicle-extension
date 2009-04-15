class AddStatusIdToVersions < ActiveRecord::Migration
  def self.up
    add_column :versions, :status_id, :integer
  end

  def self.down
    remove_column :versions, :status_id
  end
end
