require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::VersionsHelper do
  dataset :versions
  
  it "should produce a diff" do
    version = pages(:page_with_draft).versions.current
    helper.diff(version).should == "The version diff will go here."
  end
end
