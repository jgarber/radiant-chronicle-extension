module Chronicle::PageExtensions
  def self.included(base)
    base.class_eval do
      simply_versioned :keep => 10
      alias_method_chain :update_without_callbacks, :draft_versioning
      alias_method_chain :save_page_parts, :draft_versioning
      alias_method_chain :find_by_url, :draft_versioning
      alias_method_chain :simply_versioned_create_version, :extra_version_attributes
      
      # Switch callback chain order so page parts are saved to the version
      create_version_callback = @after_save_callbacks.detect {|c| c.method == :simply_versioned_create_version }
      @after_save_callbacks.delete(create_version_callback)
      @after_save_callbacks.unshift(create_version_callback)
    end
  end
  
  def update_without_callbacks_with_draft_versioning
    if self.status_id < Status[:published].id # Draft or Reviewed
      true # Don't save page; versioning callbacks will save it in the versions table
    else
      update_without_callbacks_without_draft_versioning
    end
  end
  
  def save_page_parts_with_draft_versioning
    if self.status_id < Status[:published].id # Draft or Reviewed
      # Don't save parts to the live page; callbacks will add them to the versioned page
      @page_parts = nil
      true
    else
      update_without_callbacks_without_draft_versioning
    end
  end
  
  def simply_versioned_create_version_with_extra_version_attributes
    with_associated_parts_in_attributes do
      simply_versioned_create_version_without_extra_version_attributes
    end
    
    self.versions.current.update_attributes(:slug => slug)
  end
  
  def find_by_url_with_draft_versioning(url, live = true, clean = true)
    if live
      find_by_url_without_draft_versioning(url, live, clean)
    else
      found = find_by_url_without_draft_versioning(url, live, clean)
      found = found.versions.current.instance if found && found.versioned?
      return found
    end
  end
  
  def with_associated_parts_in_attributes(&block)
    real_attributes = self.attributes
    write_attribute "parts", self.parts.map {|p| p.attributes }
    block.call
    self.attributes = real_attributes
  end
end