require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/pages/_diff.html.haml" do
  dataset :versions, :layouts
  
  before :each do
    template.extend Admin::VersionsHelper
  end
  
  it "should have a title even when title was not changed" do
    @version = pages(:published).versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("td.field", :content => "Published")
  end
  
  it "should have a changed title" do
    page = pages(:published)
    page.update_attributes(:title => "Published 2")
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "Published")
    response.should have_selector("span.to", :content => "Published 2")
  end

  it "should have a changed slug" do
    page = pages(:published)
    page.update_attributes(:slug => "published-2")
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "published")
    response.should have_selector("span.to", :content => "published-2")
  end
  
  it "should have a changed breadcrumb" do
    page = pages(:published)
    page.update_attributes(:breadcrumb => "Published page")
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "")
    response.should have_selector("span.to", :content => "Published page")
  end

  it "should have a changed description" do
    page = pages(:published)
    page.update_attributes(:description => "the description")
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "")
    response.should have_selector("span.to", :content => "the description")
  end
  
  it "should not show description when empty and no change" do
    page = pages(:published)
    page.description.should be_blank
    page.save! # new version
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should_not contain("Description")
  end
  
  it "should have a changed keywords" do
    page = pages(:published)
    page.update_attributes(:keywords => "the keywords")
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "")
    response.should have_selector("span.to", :content => "the keywords")
  end
  
  it "should not show keywords when empty and no change" do
    page = pages(:published)
    page.keywords.should be_blank
    page.save! # new version
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should_not contain("Keywords")
  end
  
  it "should show the parts' diffs" do
    page = pages(:published)
    page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"Changed body"}]
    page.save
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("div.page", :content => "Changed body")
  end
  
  it "should have a changed layout" do
    page = pages(:published)
    page.update_attributes(:layout_id => layout_id(:main))
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "")
    response.should have_selector("span.to", :content => "Main")
  end
  
  it "should have a changed page type" do
    page = pages(:published)
    page.update_attributes(:class_name => "ArchivePage")
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "<normal>")
    response.should have_selector("span.to", :content => "ArchivePage")
  end
  
  it "should have a changed status" do
    page = pages(:published)
    page.update_attributes(:status_id => Status[:draft].id)
    @version = page.versions.current
    render 'admin/pages/_diff.html.haml', :locals => {:version => @version}
    response.should have_selector("span.from", :content => "Published")
    response.should have_selector("span.to", :content => "Draft")
  end
  
  
end