class AddStatusToSnippetsAndLayouts < ActiveRecord::Migration
  def self.up
    add_column :layouts, :status_id, :integer, :default => Status[:published].id
    add_column :snippets, :status_id, :integer, :default => Status[:published].id
  end

  def self.down
    remove_column :layouts, :status_id
    remove_column :snippets, :status_id
  end
end
