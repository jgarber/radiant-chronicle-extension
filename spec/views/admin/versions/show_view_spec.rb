require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/versions/show" do
  dataset :versions
  
  describe "first version" do
    before do
      @version = pages(:updated_by_existing).versions.first
      assigns[:version] = @version
      render 'admin/versions/show'
    end
    
    it "should display the created_by name instead of the updated_by name" do
      response.should have_selector("span.version-author", :content => "Admin")
    end
    
  end

  describe "second version" do
    before do
      @version = pages(:updated_by_existing).versions.current
      @version.instance.stub!(:updated_at).and_return Time.local(2009,1,1,8,57)
      assigns[:version] = @version
      render 'admin/versions/show'
    end 
  
    it "should display the version number" do
      response.should have_selector("span.version-number", :content => "Version 2")
    end
  
    it "should display the author" do
      response.should have_selector("span.version-author", :content => "Existing")
    end
  
    it "should display the update time" do
      response.should have_selector("span.version-updated-at", :content => "01 Jan 08:57")
    end
  
    it "should display the status" do
      response.should have_selector("span.version-status", :content => "Published")
    end
  end  
end
