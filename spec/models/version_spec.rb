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
end