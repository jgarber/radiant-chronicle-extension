require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::VersionsHelper do
  
  describe "#format_diff" do
    it "should format a diff array with two elements" do
      helper.format_diff(["Foo", "Bar"]).should == %Q{<span class="from">Foo</span> &rarr; <span class="to">Bar</span>}
    end
    
    it "should format a diff array with one element" do
      helper.format_diff(["Foo"]).should == "Foo"
    end
    
    it "should format a diff array with two identical elements as if one" do
      helper.format_diff(["Foo", "Foo"]).should == "Foo"
    end
  end
  
  describe "#field_diff" do
    it "should format a field's diff output when the field changes" do
      version = stub(Version)
      instance = stub(Page)
      instance.stub!(:title).and_return("The Page Title")
      version.stub!(:instance).and_return(instance)
      version.stub!(:diff).and_return(:title => ["Foo", "Bar"])
      
      helper.field_diff(version, :title).should == helper.format_diff(["Foo", "Bar"])
    end
    it "should use the field from the instance when not present in the diff hash" do
      version = stub(Version)
      instance = stub(Page)
      instance.stub!(:title).and_return("Foo")
      version.stub!(:instance).and_return(instance)
      version.stub!(:diff).and_return({})
      
      helper.field_diff(version, :title).should == "Foo"
    end
    it "should return an empty string by default when a field is empty" do
      version = stub(Version)
      instance = stub(Page)
      instance.stub!(:class_name).and_return("")
      version.stub!(:instance).and_return(instance)
      version.stub!(:diff).and_return({})
      
      helper.field_diff(version, :class_name).should == ""
    end
    it "should return the provided empty_value when a field is empty" do
      version = stub(Version)
      instance = stub(Page)
      instance.stub!(:class_name).and_return("")
      version.stub!(:instance).and_return(instance)
      version.stub!(:diff).and_return({})
      
      helper.field_diff(version, :class_name, "empty").should == "empty"
    end
    it "should return the provided empty_value when changing to or from empty value" do
      version = stub(Version)
      version.stub!(:diff).and_return({:class_name => ["", "ArchivePage"]})
      
      helper.field_diff(version, :class_name, "empty").should == helper.format_diff(["empty", "ArchivePage"])
    end
    it "should HTML-escape the provided empty_value" do
      version = stub(Version)
      instance = stub(Page)
      instance.stub!(:class_name).and_return(nil)
      version.stub!(:instance).and_return(instance)
      version.stub!(:diff).and_return({})
      
      helper.field_diff(version, :class_name, "<normal>").should == "&lt;normal&gt;"
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
      helper.layout_diff(version).should == helper.format_diff(["Foo", "Bar"])
    end
    
    it "should format the layout field's diff output when layout changed from nil" do
      version = stub(Version)
      layout_2 = mock_model(Layout)
      layout_2.should_receive(:name).and_return("Bar")
      Layout.should_receive(:find).once.with(layout_2.id).and_return(layout_2)
      version.stub!(:diff).and_return(:layout_id => [nil, layout_2.id])
      helper.layout_diff(version).should == helper.format_diff(["&lt;inherit&gt;", "Bar"])
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
    
    it "should the layout inherits when nil and no change" do
      version = stub(Version)
      instance = stub(Page)
      instance.stub!(:layout_id).and_return(nil)
      version.stub!(:instance).and_return(instance)
      version.stub!(:diff).and_return({})
      helper.layout_diff(version).should == "&lt;inherit&gt;"
    end
  end
  
  describe "#status_diff" do
    it "should format the status field's diff output when status_id changed" do
      version = stub(Version)
      version.stub!(:diff).and_return(:status_id => [Status[:draft].id, Status[:published].id])
      helper.status_diff(version).should == helper.format_diff(["Draft", "Published"])
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
        helper.stub!(:render).and_return("rendered part")
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
        helper.should_receive(:render).with(hash_including(:partial => 'admin/versions/part_diff.html.haml')).and_return("rendered part")
        diff = [{"name" => "body", "content" => "A", "filter_id" => ""},{"name" => "body", "content" => "B", "filter_id" => ""}]
        helper.part_diff(diff)
      end
      
      it "should render the 'part_nodiff' partial when part not changed" do
        diff = [{"name" => "body", "content" => "A", "filter_id" => ""}]
        helper.should_receive(:render).with(hash_including(:partial => 'admin/versions/part_nodiff.html.haml', :locals => {:part => diff.first})).and_return("rendered part")
        helper.part_diff(diff)
      end
      
      it "should render the 'part_nodiff' partial when part is added" do
        diff = [nil,{"name" => "body", "content" => "", "filter_id" => ""}]
        helper.should_receive(:render).with(hash_including(:partial => 'admin/versions/part_nodiff.html.haml', :locals => {:part => diff.last})).and_return("rendered part")
        helper.part_diff(diff)
      end
      
      it "should render the 'part_nodiff' partial when part is deleted" do
        diff = [{"name" => "body", "content" => "", "filter_id" => ""},nil]
        helper.should_receive(:render).with(hash_including(:partial => 'admin/versions/part_nodiff.html.haml', :locals => {:part => diff.first})).and_return("rendered part")
        helper.part_diff(diff)
      end
    end
  end
end
