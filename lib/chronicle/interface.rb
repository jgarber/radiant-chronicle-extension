module Chronicle::Interface
  def self.included(base)
    base.class_eval {
      before_filter :add_chronicle_stylesheet, :only => [:index, :edit, :new]
      before_filter :add_chronicle_javascript, :only => [:edit, :new]
      include InstanceMethods
      helper 'admin/timeline' do
        alias_method_chain :page_edit_javascripts, :timeline_bubbles
      end
    }
  end
  
  module InstanceMethods
    def add_chronicle_stylesheet
      include_stylesheet 'admin/chronicle'
    end
    def add_chronicle_javascript
      include_javascript 'admin/HelpBalloon'
    end
  end
end