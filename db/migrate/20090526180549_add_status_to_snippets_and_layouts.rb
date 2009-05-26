class AddStatusToSnippetsAndLayouts < ActiveRecord::Migration
  def self.up
    add_column :layouts, :status_id, :integer
    add_column :snippets, :status_id, :integer
  end

  def self.down
    remove_column :layouts, :status_id
    remove_column :snippets, :status_id
  end
end
