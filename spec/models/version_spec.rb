require File.dirname(__FILE__) + '/../spec_helper'

describe Version do
  dataset :versions
  
  it "should respond to #instance" do
    version = pages(:page_with_draft).versions.current
    version.instance.should be_a(Page)
  end
  
  it "should respond to #current?" do
    version = pages(:page_with_draft).versions.current
    version.current?.should be_true

    version = pages(:page_with_draft).versions.first
    version.current?.should be_false
  end
  
  it "should respond to #current_dev?" do
    version = pages(:page_with_draft).versions.current
    version.current_dev?.should == version.current?
  end
  
  it "should be current_live when " do
    version = pages(:page_with_draft).versions.first
    version.number.should == 1
    version.should be_current_live
  end
  
  it "should not be current_live when not the latest published or hidden" do
    page = pages(:published_with_many_versions)
    
    version = page.versions.first
    version.number.should == 1
    version.should_not be_current_live
    
    version = page.versions.current
    version.number.should == 3
    version.should be_current_live
  end
end