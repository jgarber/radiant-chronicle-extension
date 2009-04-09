module Chronicle::Interface
  def self.included(base)
    base.class_eval {
      before_filter :add_chronicle_stylesheet, :only => [:edit, :new]
      include InstanceMethods
    }
  end
  
  module InstanceMethods
    def add_chronicle_stylesheet
      include_stylesheet 'admin/chronicle'
    end
  end
end