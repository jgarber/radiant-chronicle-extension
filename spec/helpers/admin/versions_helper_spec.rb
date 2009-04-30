require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::VersionsHelper do
  
  describe "#field_diff" do
    it "should format a field's diff output" do
      helper.field_diff(["Foo"]).should == "Foo"
      helper.field_diff(["Foo", "Bar"]).should == %Q{<span class="from">Foo</span> &rarr; <span class="to">Bar</span>}
    end
  end

  describe "#layout_diff" do
    it "should format the layout field's diff output when layout changed" do
      version = stub(Version)
      layout_1 = mock_model(Layout)
      layout_1.should_receive(:name).and_return("Foo")
      layout_2 = mock_model(Layout)
      layout_2.should_receive(:name).and_return("Bar")
      Layout.should_receive(:find).twice.and_return(layout_1, layout_2)
      version.stub!(:diff).and_return(:layout_id => [layout_1.id, layout_2.id])
      helper.layout_diff(version).should == helper.field_diff(["Foo", "Bar"])
    end
    
    it "should format the layout field's diff output when layout changed from nil" do
      version = stub(Version)
      layout_2 = mock_model(Layout)
      layout_2.should_receive(:name).and_return("Bar")
      Layout.should_receive(:find).once.with(layout_2.id).and_return(layout_2)
      version.stub!(:diff).and_return(:layout_id => [nil, layout_2.id])
      helper.layout_diff(version).should == helper.field_diff(["", "Bar"])
    end
    
    it "should format the layout field when no change" do
      version = stub(Version)
      layout_1 = mock_model(Layout)
      layout_1.should_receive(:name).and_return("Foo")
      Layout.should_receive(:find).once.with(layout_1.id).and_return(layout_1)
      instance = stub(Page)
      instance.stub!(:layout_id).and_return(layout_1.id)
      version.stub!(:instance).and_return(instance)
      version.stub!(:diff).and_return({})
      helper.layout_diff(version).should == "Foo"
    end
  end
  
  describe "#status_diff" do
    it "should format the status field's diff output when status_id changed" do
      version = stub(Version)
      version.stub!(:diff).and_return(:status_id => [Status[:draft].id, Status[:published].id])
      helper.status_diff(version).should == helper.field_diff(["Draft", "Published"])
    end
    
    it "should format the status field when no change" do
      version = stub(Version)
      instance = stub(Page)
      instance.stub!(:status_id).and_return(Status[:published].id)
      version.stub!(:instance).and_return(instance)
      version.stub!(:diff).and_return({})
      helper.status_diff(version).should == "Published"
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
