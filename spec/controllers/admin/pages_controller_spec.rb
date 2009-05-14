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
  
  describe "previewing a page" do
    integrate_views
    
    it "should redirect to the page on the same host by default" do
      get :show, :id => page_id(:first)
      response.should be_redirect
      response.should redirect_to(pages(:first).url)
    end
    
    it "should redirect to the live page when live mode is specified" do
      get :show, :id => page_id(:first), :mode => 'live'
      response.should be_redirect
      response.should redirect_to("http://test.host" + pages(:first).url)
    end
    
    it "should redirect to the dev page when dev mode is specified" do
      get :show, :id => page_id(:first), :mode => 'dev'
      response.should be_redirect
      response.should redirect_to("http://dev.test.host" + pages(:first).url)
    end
    
    it "should render waiting for save page when lock_version doesn't yet exist" do
      get :show, :id => page_id(:first), :lock_version => pages(:first).lock_version + 1
      response.should be_success
      response.should render_template("admin/pages/show")
    end
    
    it "should redirect when lock_version does exist" do
      get :show, :id => page_id(:first), :lock_version => pages(:first).lock_version
      response.should be_redirect
      response.should redirect_to("http://dev.test.host" + pages(:first).url)
    end
    
    it "should return rjs when the waiting page inquires about the status and lock_version doesn't yet exist" do
      xhr :get, :show, :id => page_id(:first), :lock_version => pages(:first).lock_version + 1, :delay => 50
      response.should be_success
      response.should render_template("admin/pages/show")
      response.should have_text("wait_then_check_if_saved(100);")
    end
    
    it "should render redirect rjs when lock_version does exist" do
      xhr :get, :show, :id => page_id(:first), :lock_version => pages(:first).lock_version
      response.should be_success
      response.should have_text(%{window.location.href = "http://dev.test.host/first/";})
    end
    
  end
end