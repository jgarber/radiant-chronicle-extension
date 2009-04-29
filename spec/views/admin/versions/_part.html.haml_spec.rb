require File.dirname(__FILE__) + '/../../../spec_helper'

describe "admin/versions/_part.html.haml" do
  before(:each) do
    @part = {"name" => "body", "content" => "A", "filter_id" => "Textile"}
    render :partial => 'admin/versions/part', :locals => {:part => @part}
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