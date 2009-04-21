require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "admin/_version.html.haml" do
  dataset :users_and_pages
  
  before(:each) do
    page = pages(:first)
    page.updated_at = Time.local(2009,1,1,8,57)
    @version = stub("Version")
    @version.stub!(:number).and_return 2
    @version.stub!(:instance).and_return page
    assigns[:version] = @version
  end 
  
  it "should display the version number" do
    render "admin/_version.html.haml" 
    response.should have_selector("span#version-number", :content => "Version 2")
  end
  
  it "should display the author" do
    render "admin/_version.html.haml" 
    response.should have_selector("span#version-author", :content => "Admin")
  end
  
  it "should display the update time" do
    render "admin/_version.html.haml" 
    response.should have_selector("span#version-updated-at", :content => "01 Jan 08:57")
  end
  
  it "should display the status" do
    render "admin/_version.html.haml" 
    response.should have_selector("span#version-status", :content => "Published")
  end
end
