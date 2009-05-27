require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::LayoutsController do
  dataset :users, :layouts
  
  before :each do
    login_as :developer
  end

  describe "editing a layout" do
    integrate_views
    
    before :each do
      @layout = layouts(:main)
      @layout.update_attributes(:content => "foobar", :status_id => Status[:draft].id)
    end
    
    def do_get
      get :edit, :id => @layout.id
    end
    
    it "should load the latest version of the layout" do
      do_get
      assigns[:layout].content.should == "foobar"
    end
    
    it "should have a version diff popup" do
      do_get
      response.should have_selector("div#version-diff-popup")
    end
  end
end