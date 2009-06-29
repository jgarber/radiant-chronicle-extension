class ConvertVersionedAssociationFromHashToObject < ActiveRecord::Migration
  def self.up
    Version.find(:all).each do |version|
      attributes = YAML::load(version.yaml)
      if attributes["parts"]
        attributes["parts"].collect! do |part_attributes|
          part = PagePart.find_by_page_id_and_name(version.versionable_id, part_attributes["name"])
          part_attributes.delete("page_id")
          part.attributes = part_attributes
          part
        end
        version.update_attributes( :yaml => attributes.to_yaml )
      end
    end
  end

  def self.down
    Version.find(:all).each do |version|
      attributes = YAML::load(version.yaml)
      if attributes["parts"]
        attributes["parts"].collect! do |part|
          part.attributes
        end
        version.update_attributes( :yaml => attributes.to_yaml )
      end
    end
  end
end
