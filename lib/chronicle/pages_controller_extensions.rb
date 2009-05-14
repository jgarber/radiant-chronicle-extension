module Chronicle::PagesControllerExtensions
  def self.included(base)
    base.class_eval {
      before_filter :add_chronicle_stylesheet, :only => [:index, :edit, :new]
      before_filter :add_chronicle_javascript, :only => [:edit, :new]
      include InstanceMethods
      helper 'admin/preview', 'admin/timeline'
      include Admin::PreviewHelper
    }
  end
  
  module InstanceMethods
    def show
      if params[:lock_version]
        if @page = Page.find_by_id_and_lock_version(params[:id], params[:lock_version])
          redirect_url = dev_page_url(@page)
          respond_to do |format|
            format.html { redirect_to redirect_url }
            format.js { render(:update) { |page| page.redirect_to redirect_url } }
          end
        else
          respond_to :html, :js
        end
      else
        @page = Page.find(params[:id])
        case params[:mode]
        when 'live'
          redirect_to live_page_url(@page)
        when 'dev'
          redirect_to dev_page_url(@page)
        else
          redirect_to @page.url
        end
      end
    end
    
    def add_chronicle_stylesheet
      include_stylesheet 'admin/chronicle'
    end
    def add_chronicle_javascript
      include_javascript 'admin/HelpBalloon'
      include_javascript 'admin/chronicle'
    end
  end
end