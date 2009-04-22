class Admin::VersionsController < ApplicationController
  def show
    @version = Version.find(params[:id])
    respond_to do |wants|
      wants.html
      # wants.xml
      # wants.js
    end
  end

end
