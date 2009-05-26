require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SnippetsController do
  dataset :users, :snippets
  
  before :each do
    login_as :developer
  end

  describe "editing a snippet" do
    integrate_views
    
    before :each do
      @snippet = snippets(:first)
      @snippet.update_attributes(:content => "foobar", :status_id => Status[:draft].id)
    end
    
    def do_get
      get :edit, :id => @snippet.id
    end
    
    it "should load the latest version of the snippet" do
      do_get
      assigns[:snippet].content.should == "foobar"
    end
    
    it "should have a version diff popup" do
      do_get
      response.should have_selector("div#version-diff-popup")
    end
  end
end