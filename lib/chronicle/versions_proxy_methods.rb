module Chronicle
  module VersionsProxyMethods
    def current_live
      find(:first,
            :conditions => ["status_id >= ?", Status[:published].id],
            :order => 'number DESC')
    end
  end
end