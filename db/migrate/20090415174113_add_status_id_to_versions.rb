class AddStatusIdToVersions < ActiveRecord::Migration
  def self.up
    add_column :versions, :status_id, :integer
    
    Version.reset_column_information 
    Version.all.each do |version|
      version.status_id = version.instance.status_id
      version.save
    end
  end

  def self.down
    remove_column :versions, :status_id
  end
end
