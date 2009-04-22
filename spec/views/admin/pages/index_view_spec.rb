require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/pages/" do
  dataset :versions
  
  describe "modified node view" do
    it "should have published plus draft" do
      page = pages(:page_with_draft)
      render_node(page)
      response.should have_selector("td", :class => "published-status status") do |td|
        td.should have_selector("span", :class => "draft-status status", :content => "+ Draft")
      end
    end
    
    it "should have published plus reviewed" do
      page = pages(:page_with_reviewed)
      render_node(page)
      response.should have_selector("td", :class => "published-status status") do |td|
        td.should have_selector("span", :class => "reviewed-status status", :content => "+ Reviewed")
      end
    end
    
    it "should not have published plus draft if it is a draft" do
      page = pages(:draft)
      render_node(page)
      response.should_not have_selector("span", :content => "+ Draft")
    end
    
    it "should not have published plus reviewed if it is reviewed" do
      page = pages(:reviewed)
      render_node(page)
      response.should_not have_selector("span", :content => "+ Reviewed")
    end
    
    def render_node(page)
      assigns[:level] = 0
      render "admin/pages/children", :locals => {:models => [page]}
    end
  end
  
end