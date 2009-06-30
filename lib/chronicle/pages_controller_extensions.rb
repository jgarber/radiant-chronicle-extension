module Chronicle::PagesControllerExtensions
  def self.included(base)
    base.class_eval {
      include InstanceMethods
      alias_method_chain :announce_saved, :show_page
      helper 'admin/preview'
      include Admin::PreviewHelper
    }
  end
  
  module InstanceMethods
    def announce_saved_with_show_page(message = nil)
      announce_saved_without_show_page(message)
      if params[:view_after_saving]
        flash[:javascript] = <<-EOD
          previewWindow = window.open("#{dev_page_url(@page)}","radiant_cms_page_preview"); 
          if (window.focus) {previewWindow.focus();}
        EOD
      end
      session[:view_after_saving] = params[:view_after_saving]
    end
    
  end
end