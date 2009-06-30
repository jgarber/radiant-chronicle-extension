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
    
    before(:each) do
      @page = pages(:first)
    end
    
    it "should add javascript to the flash when view_after_saving is set" do
      put :update, :id=>@page.id, "continue"=>"Save and Continue Editing", "page"=>params_for_page(@page), "view_after_saving"=>"1"
      response.should be_redirect
      flash[:javascript].should =~ %r{window.open}
    end

    it "should not add javascript to the flash when view_after_saving is not set" do
      put :update, :id=>@page.id, "continue"=>"Save and Continue Editing", "page"=>params_for_page(@page)
      response.should be_redirect
      flash[:javascript].should be_nil
    end
    
    it "should set view_after_saving in the session when view_after_saving is set" do
      put :update, :id=>@page.id, "continue"=>"Save and Continue Editing", "page"=>params_for_page(@page), "view_after_saving"=>"1"
      response.should be_redirect
      session[:view_after_saving].should be_true
    end
    
    it "should unset view_after_saving in the session when view_after_saving is not set" do
      session[:view_after_saving] = true
      put :update, :id=>@page.id, "continue"=>"Save and Continue Editing", "page"=>params_for_page(@page)
      response.should be_redirect
      session[:view_after_saving].should_not be_true
    end
    
  end
  
  def params_for_page(page)
    {"slug"=>page.slug, "class_name"=>page.class_name, "title"=>page.title, "breadcrumb"=>page.breadcrumb, "lock_version"=>page.lock_version, "parts_attributes"=>[{"name"=>"body", "filter_id"=>"", "content"=>"test"}], "status_id"=>page.status_id, "layout_id"=>page.layout_id, "parent_id"=>page.parent_id}
  end
end