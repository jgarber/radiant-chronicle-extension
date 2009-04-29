require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::VersionsHelper do
  
  describe "#field_diff" do
    it "should format a field's diff output" do
      helper.field_diff(["Foo"]).should == "Foo"
      helper.field_diff(["Foo", "Bar"]).should == %Q{<span class="from">Foo</span> &rarr; <span class="to">Bar</span>}
    end
  end
  
  describe "#part_diff" do
    describe "page wrapper" do
      before(:each) do
        helper.should_receive(:render).and_return("rendered part")
      end
    
      it "should have a 'page' class" do
        diff = [{"name" => "body", "content" => "A", "filter_id" => ""},{"name" => "body", "content" => "B", "filter_id" => ""}]
        helper.part_diff(diff).should have_selector("div", :class => "page")
      end
      
      it "should have just a 'page' class when part not changed" do
        diff = [{"name" => "body", "content" => "A", "filter_id" => ""}]
        helper.part_diff(diff).should have_selector("div", :class => "page")
      end
    
      it "should also have an 'added' class when part is added" do
        diff = [nil,{"name" => "body", "content" => "", "filter_id" => ""}]
        helper.part_diff(diff).should have_selector("div", :class => "page added")
      end
    
      it "should also have a 'deleted' class when part is deleted" do
        diff = [{"name" => "body", "content" => "", "filter_id" => ""},nil]
        helper.part_diff(diff).should have_selector("div", :class => "page deleted")
      end
    end
    
    describe "rendering" do
      it "should render the 'part_diff' partial when part changed" do
        helper.should_receive(:render).with(hash_including(:partial => 'part_diff')).and_return("rendered part")
        diff = [{"name" => "body", "content" => "A", "filter_id" => ""},{"name" => "body", "content" => "B", "filter_id" => ""}]
        helper.part_diff(diff)
      end
      
      it "should render the 'part' partial when part not changed" do
        diff = [{"name" => "body", "content" => "A", "filter_id" => ""}]
        helper.should_receive(:render).with(hash_including(:partial => 'part', :locals => {:part => diff.first})).and_return("rendered part")
        helper.part_diff(diff)
      end
      
      it "should render the 'part' partial when part is added" do
        diff = [nil,{"name" => "body", "content" => "", "filter_id" => ""}]
        helper.should_receive(:render).with(hash_including(:partial => 'part', :locals => {:part => diff.last})).and_return("rendered part")
        helper.part_diff(diff)
      end
      
      it "should render the 'part' partial when part is deleted" do
        diff = [{"name" => "body", "content" => "", "filter_id" => ""},nil]
        helper.should_receive(:render).with(hash_including(:partial => 'part', :locals => {:part => diff.first})).and_return("rendered part")
        helper.part_diff(diff)
      end
    end
  end
end
