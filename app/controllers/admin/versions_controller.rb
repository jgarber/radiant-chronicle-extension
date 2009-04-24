class Admin::VersionsController < ApplicationController
  def show
    @version = Version.find(params[:id])
    respond_to do |wants|
      wants.html { render :layout => false }
      # wants.xml
      # wants.js
    end
  end
  
  def diff
    @version = Version.find(params[:id])
    respond_to do |format|
      format.any #{ render :action => params[:id] }
    end
  end

end
