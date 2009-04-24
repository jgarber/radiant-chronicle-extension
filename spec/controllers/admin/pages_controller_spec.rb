require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PagesController do
  dataset :users, :pages

  before :each do
    login_as :existing
  end
  
  describe "editing a page" do
    integrate_views
    
    it "should load the current version for editing" do
      page = pages(:first)
      page.title = "Draft of First"
      page.status = Status[:draft]
      page.save
      
      get :edit, :id => page.id
      
      assigns[:page].title.should == page.current.title
    end
    
    it "should have the version diff popup" do
      get :edit, :id => page_id(:first)
      response.should be_success
      response.should have_selector("div#version-diff-popup")
    end
  end
end