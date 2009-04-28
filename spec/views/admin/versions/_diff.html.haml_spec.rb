require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/versions/_diff.html.haml" do
  dataset :versions
  
  it "should have a title even when title was not changed" do
    @version = pages(:published).versions.current
    render 'admin/versions/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("td.field", :content => "Published")
  end
  
  it "should have a changed title" do
    page = pages(:published)
    page.update_attributes(:title => "Published 2")
    @version = page.versions.current
    render 'admin/versions/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "Published")
    response.should have_selector("span.to", :content => "Published 2")
  end

  it "should have a changed slug" do
    page = pages(:published)
    page.update_attributes(:slug => "published-2")
    @version = page.versions.current
    render 'admin/versions/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "published")
    response.should have_selector("span.to", :content => "published-2")
  end
end