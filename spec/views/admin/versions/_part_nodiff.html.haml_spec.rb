require File.dirname(__FILE__) + '/../../../spec_helper'

describe "admin/versions/_part_nodiff.html.haml" do
  describe "when no fields are blank" do
    before(:each) do
      @part = {"name" => "body", "content" => "A", "filter_id" => "Textile"}
      render :partial => 'admin/versions/part_nodiff.html.haml', :locals => {:part => @part}
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
  
  it "should not show the filter label when filter is blank" do
    @part = {"name" => "body", "content" => "A", "filter_id" => ""}
    render :partial => 'admin/versions/part_nodiff.html.haml', :locals => {:part => @part}
    response.should_not have_selector("p", :class => 'filter')
  end
end