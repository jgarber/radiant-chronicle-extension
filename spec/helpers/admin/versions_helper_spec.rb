require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::VersionsHelper do
  
  describe "#field_diff" do
    it "should format a field's diff output" do
      helper.field_diff(["Foo"]).should == "Foo"
      helper.field_diff(["Foo", "Bar"]).should == %Q{<span class="from">Foo</span> &rarr; <span class="to">Bar</span>}
    end
  end
end
