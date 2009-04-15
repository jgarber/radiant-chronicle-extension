require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::TimelineHelper do
  dataset :versions
  
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(Admin::TimelineHelper)
  end
  
  it "should produce a dev flag on a first-version draft" do
    page = pages(:draft)
    helper.timeline(page).should have_version(1).as(:draft) do |li|
      li.should have_marker(:dev)
    end
  end

  it "should produce a dev flag on a first-version reviewed page" do
    page = pages(:reviewed)
    helper.timeline(page).should have_version(1).as(:reviewed) do |li|
      li.should have_marker(:dev)
    end
  end

  it "should produce a dev+live flag on a first-version hidden page" do
    page = pages(:hidden)
    helper.timeline(page).should have_version(1).as(:hidden) do |li|
      li.should have_marker("dev-and-live")
    end
  end

  it "should produce a live flag on live version of published page with draft" do
    page = pages(:page_with_draft)
    helper.timeline(page).should have_version(1).as(:published) do |li|
      li.should have_marker(:live)
    end
  end
  
  it "should produce a dev flag on current version of published page with draft" do
    page = pages(:page_with_draft)
    helper.timeline(page).should have_version(2).as(:draft) do |li|
      li.should have_marker(:dev)
    end
  end
  
  it "should produce a live+dev flag on a current published page" do
    page = pages(:published)
    helper.timeline(page).should have_version(1).as(:published) do |li|
      li.should have_marker("dev-and-live")
    end
  end
  
  it "should not put a marker on a published version that is not current live" do
    page = pages(:published_with_many_versions)
    helper.timeline(page).should have_version(1).as(:published) do |li|
      li.should_not have_marker
    end
  end
  
  it "should not put a marker on a draft version that is not current dev" do
    page = pages(:draft_with_many_versions)
    helper.timeline(page).should have_version(1).as(:draft) do |li|
      li.should_not have_marker
    end
  end
  
  def have_marker(type=nil)
    opts = {:class=>"marker"}
    if type
      type = type.to_s
      opts.merge! :id=>"#{type}-marker", :src=>"/images/admin/#{type}.png"
    end
    have_selector("img", opts)
  end

end