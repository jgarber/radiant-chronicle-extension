class Admin::VersionsController < ApplicationController
  include Chronicle::Interface
  before_filter :add_chronicle_stylesheet, :only => [:index, :show, :summary, :diff]
  
  def index
    @versions = Version.find(:all, :order => "created_at DESC")
  end

  def show
    @version = Version.find(params[:id])
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
