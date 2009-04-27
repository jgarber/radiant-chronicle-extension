module Chronicle::PageExtensions
  def self.included(base)
    base.class_eval do
      simply_versioned
      alias_method_chain :update_without_callbacks, :draft_versioning
      alias_method_chain :save_page_parts, :draft_versioning
      alias_method_chain :find_by_url, :draft_versioning
      alias_method_chain :simply_versioned_create_version, :extra_version_attributes
      alias_method_chain :url, :draft_awareness
      
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
      save_page_parts_without_draft_versioning
    end
  end
  
  def simply_versioned_create_version_with_extra_version_attributes
    with_associated_parts_in_attributes do
      simply_versioned_create_version_without_extra_version_attributes
    end
    
    self.versions.current.update_attributes(:slug => slug, :status_id => status_id, :diff => diff)
  end
  
  # Works the same as #find_by_url when in live mode, but in dev mode, finds
  # the URL using the most current versions (which may be draft versions ahead
  # of the live version)
  def find_by_url_with_draft_versioning(url, live = true, clean = true)
    if live
      find_by_url_without_draft_versioning(url, live, clean)
    else
      return nil if virtual?
      url = clean_url(url) if clean
      my_url = self.url(live)
      if (my_url == url) && (not live or published?)
        self.current
      elsif (url =~ /^#{Regexp.quote(my_url)}([^\/]*)/)
        slug_child = current_children.find {|child| child.slug == $1 }
        if slug_child
          found = slug_child.find_by_url(url, live, clean)
          return found if found
        end
        current_children.each do |child|
          found = child.find_by_url(url, live, clean)
          return found if found
        end
        file_not_found_types = ([FileNotFoundPage] + FileNotFoundPage.descendants)
        file_not_found_names = file_not_found_types.collect { |x| x.name }
        condition = (['class_name = ?'] * file_not_found_names.length).join(' or ')
        condition = "status_id = #{Status[:published].id} and (#{condition})" if live
        children.find(:first, :conditions => [condition] + file_not_found_names).current
      end
    end
  end
  
  # The most recent version of the page, possibly ahead of the live version
  def current
    self.versioned? ? self.versions.current.instance : self
  end
  
  # The most recent versions of children
  def current_children
    children.map {|c| c.current }
  end
  
  # The #url method should be aware that it's a child of a draft
  def url_with_draft_awareness(live = true)
    if !live && parent
      parent.current.child_url(self)
    else
      url_without_draft_awareness
    end
  end
  
  def with_associated_parts_in_attributes(&block)
    real_attributes = self.attributes
    write_attribute "parts", self.parts.map {|p| p.attributes }
    block.call
    self.attributes = real_attributes if self.status_id < Status[:published].id
  end
  
  def diff
    result = changes
    parts_diff = self.parts.map do |new_part|
      old_part = self.parts_without_pending.find_by_name(new_part.name)
      new_part_attributes = new_part.attributes_for_diff
      if old_part.nil?
        [nil, new_part_attributes] # Added part
      else
        old_part_attributes = old_part.attributes_for_diff
        if old_part_attributes == new_part_attributes # Because #uniq doesn't work to eliminate duplicate hashes in an array
          [new_part_attributes] # Unchanged part
        else
          [old_part_attributes, new_part_attributes] # Changed part
        end
      end
    end
    deleted_part_names = self.parts_without_pending.map(&:name) - self.parts.map(&:name)
    deleted_part_names.each do |name|
      old_part = self.parts_without_pending.find_by_name(name)
      parts_diff << [old_part.attributes_for_diff, nil] # Deleted part
    end
    result.merge("parts" => parts_diff)
  end
end