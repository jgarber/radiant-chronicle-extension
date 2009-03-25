module Chronicle::PageExtensions
  def self.included(base)
    base.class_eval do
      simply_versioned :keep => 10
      alias_method_chain :update_without_callbacks, :draft_versioning
      alias_method_chain :save_page_parts, :draft_versioning
      alias_method_chain :attributes, :page_parts
      
      # Switch callback chain order so page parts are saved to the version
      create_version_callback = @after_save_callbacks.detect {|c| c.method == :simply_versioned_create_version }
      @after_save_callbacks.delete(create_version_callback)
      @after_save_callbacks.unshift(create_version_callback)
    end
  end
  
  def update_without_callbacks_with_draft_versioning
    if self.status_id < Status[:published].id # Draft or Reviewed
      true # Don't save; versioning callbacks will save it in the versions table
    else
      update_without_callbacks_without_draft_versioning
    end
  end
  
  def save_page_parts_with_draft_versioning
    if self.status_id < Status[:published].id # Draft or Reviewed
      # Don't save to the live page; callbacks will add them to the versioned page
      @page_parts = nil
      true
    else
      update_without_callbacks_without_draft_versioning
    end
  end
  
  def attributes_with_page_parts
    attrs = attributes_without_page_parts
    attrs["parts"] = self.parts.map {|p| p.attributes }
    attrs
  end
end