class AddVersionsTable < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.integer   :versionable_id
      t.string    :versionable_type
      t.integer   :number
      t.string    :slug
      t.text      :yaml
      t.text      :diff
      t.integer   :parent_version_id
      t.datetime  :created_at
    end
    
    add_index :versions, [:versionable_id, :versionable_type]
  end
  
  def self.down
    drop_table :versions
  end
end
