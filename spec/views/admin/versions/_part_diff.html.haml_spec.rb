require File.dirname(__FILE__) + '/../../../spec_helper'

describe "admin/versions/_part_diff.html.haml" do  
  describe "when fields do not change" do
    before(:each) do
      @previous, @current = {"name" => "body", "content" => "A", "filter_id" => "Textile"}, {"name" => "body", "content" => "A", "filter_id" => "Textile"}
      render :partial => 'admin/versions/part_diff', :locals => {:previous => @previous, :current => @current}
    end

    it "should have the part name" do
      response.should have_selector("h4", :class => 'name', :content => 'body')
    end
  
    it "should have the filter" do
      response.should have_selector("p", :class => 'filter', :content => "Textile")
    end

    it "should have the content" do
      response.should have_selector("pre", :content => "A")
    end
  end
  
  describe "when fields do change" do
    before(:each) do
      @previous, @current = {"name" => "body", "content" => "A", "filter_id" => "Textile"}, {"name" => "body", "content" => "B", "filter_id" => "Markdown"}
      render :partial => 'admin/versions/part_diff', :locals => {:previous => @previous, :current => @current}
    end
  
    it "should have a changed filter" do
      response.should have_selector("p", :class => 'filter') do
        response.should have_selector("span.from", :content => "Textile")
        response.should have_selector("span.to", :content => "Markdown")
      end
    end

    it "should have changed content" do
      response.should have_selector("pre") do
        response.should have_selector("del", :content => "A")
        response.should have_selector("ins", :content => "B")
      end
    end
  end
end