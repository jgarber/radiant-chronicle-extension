require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/versions/show" do
  dataset :users_and_pages
  
  describe "first version" do
    before do
      page = pages(:first)
      page.stub!(:updated_by).and_return nil
      page.stub!(:created_by).and_return users(:admin)
      @version = Version.new
      @version.stub!(:number).and_return 2
      @version.stub!(:instance).and_return page
      assigns[:version] = @version
      render 'admin/versions/show'
    end
    
    it "should display the created_by name instead of the updated_by name" do
      response.should have_selector("span.version-author", :content => "Admin")
    end
    
  end

  describe "second version" do
    before do
      page = pages(:first)
      page.updated_at = Time.local(2009,1,1,8,57)
      @version = Version.new
      @version.stub!(:number).and_return 2
      @version.stub!(:instance).and_return page
      assigns[:version] = @version
      render 'admin/versions/show'
    end 
  
    it "should display the version number" do
      response.should have_selector("span.version-number", :content => "Version 2")
    end
  
    it "should display the author" do
      response.should have_selector("span.version-author", :content => "Admin")
    end
  
    it "should display the update time" do
      response.should have_selector("span.version-updated-at", :content => "01 Jan 08:57")
    end
  
    it "should display the status" do
      response.should have_selector("span.version-status", :content => "Published")
    end
  end  
end
