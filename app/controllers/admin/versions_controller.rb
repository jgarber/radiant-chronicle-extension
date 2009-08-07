class Admin::VersionsController < ApplicationController
  include Chronicle::Interface
  before_filter :add_chronicle_stylesheet, :only => [:index, :show, :summary, :diff]
  
  def index
    per_page = Radiant::Config['chronicle.history.per_page']
    @versions = Version.paginate(:page => params[:page], :order => 'created_at DESC', :per_page => per_page)
  end

  def show
    @version = Version.find(params[:id])
    @page = @version.versionable
  end

  def summary
    @version = Version.find(params[:id])
    respond_to do |wants|
      wants.html { render :layout => false }
    end
  end
  
  def diff
    @version = Version.find(params[:id])
    respond_to do |format|
      format.any #{ render :action => params[:id] }
    end
  end

end
