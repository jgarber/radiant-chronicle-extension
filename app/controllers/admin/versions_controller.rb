class Admin::VersionsController < ApplicationController
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
