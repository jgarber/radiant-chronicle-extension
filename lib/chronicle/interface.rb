module Chronicle::Interface
  def self.included(base)
    base.class_eval {
      before_filter :add_chronicle_assets, :only => [:edit, :new]
      include InstanceMethods
      helper 'admin/timeline' do
        alias_method_chain :page_edit_javascripts, :timeline_bubbles
      end
    }
  end
  
  module InstanceMethods
    def add_chronicle_assets
      include_stylesheet 'admin/chronicle'
      include_javascript 'admin/HelpBalloon'
    end
  end
end