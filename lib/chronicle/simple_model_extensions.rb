module Chronicle::SimpleModelExtensions
  def self.included(base)
    base.class_eval do
      simply_versioned
      alias_method_chain :update_without_callbacks, :draft_versioning
      alias_method_chain :simply_versioned_create_version, :extra_version_attributes
      include ActiveRecord::Diff
      case
      when base == Layout
        diff :include => [:status_id]
      when base == Snippet
        diff :include => [:status_id, :filter_id]
      end
    end
  end

  def update_without_callbacks_with_draft_versioning
    if status_id < Status[:published].id # Draft or Reviewed
      update_with_lock([self.class.locking_column]) # Only update the locking column, not other attributes
      if changed == simply_versioned_excluded_columns
        # Only non-versioned attributes were updated, so it's safe to save
        update_without_callbacks_without_draft_versioning
      else
        true # Don't save model; versioning callbacks will save it in the versions table
      end
      
    else
      update_without_callbacks_without_draft_versioning
    end
  end

  def simply_versioned_create_version_with_extra_version_attributes
    simply_versioned_create_version_without_extra_version_attributes
    self.versions.current.update_attributes(:status_id => status_id)
  end
  
  def nonversioned_attributes
    attributes.slice(*simply_versioned_excluded_columns)
  end
  
  # The most recent version of the page, possibly ahead of the live version
  def current
    self.versioned? ? self.versions.current.instance : self
  end
  alias_method :current_dev, :current

  # The most recent live version of the page
  def current_live
    self.versioned? ? self.versions.current_live.instance : self
  end
  
  def versions_with_limit(limit)
    self.versions.find(:all, :limit => limit)
  end
  
  def status
    Status.find(status_id)
  end
  
  def status=(value)
    self.status_id = value.id
  end
  
  def title
    name
  end
end