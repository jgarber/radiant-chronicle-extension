class ConvertVersionedAssociationFromHashToObject < ActiveRecord::Migration
  def self.up
    Version.find(:all).each do |version|
      attributes = YAML::load(version.yaml)
      if attributes["parts"]
        attributes["parts"].collect! do |part_attributes|
          part_attributes.delete("page_id")
          if existing_part = PagePart.find_by_page_id_and_name(version.versionable_id, part_attributes["name"])
              existing_part.attributes = part_attributes
              existing_part
          else
            PagePart.send(:instantiate, part_attributes)
          end
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
