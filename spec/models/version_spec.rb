require File.dirname(__FILE__) + '/../spec_helper'

describe Version do
  dataset :versions
  
  it "should be only visible in dev mode when status is draft" do
    version = pages(:draft).versions.current
    version.should be_only_visible_in_dev_mode
  end
  
  it "should be only visible in dev mode when status is reviewed" do
    version = pages(:reviewed).versions.current
    version.should be_only_visible_in_dev_mode
  end
  
  it "should respond to #instance" do
    version = pages(:page_with_draft).versions.current
    version.instance.should be_a(Page)
  end
  
  it "should instantiate a draft of a different class_name" do
    @page = pages(:env_dump)
    @page.class_name = ""
    @page.status_id = Status[:draft].id
    @page.save
    
    @page.class.should == EnvDumpPage
    @page.current.class.should == Page
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
  
  it "should be current_live when the latest published version" do
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
  
  describe "#saved_by" do
    it "should return updated_by from the instance" do
      page = stub("Page")
      page.stub!(:updated_by).and_return users(:admin)
      version = pages(:published).versions.current
      version.stub!(:instance).and_return page
      
      version.saved_by.should == users(:admin)
    end

    it "should return created_by from the instance when no updated_by" do
      page = stub("Page")
      page.stub!(:updated_by).and_return nil
      page.stub!(:created_by).and_return users(:admin)
      version = pages(:published).versions.current
      version.stub!(:instance).and_return page
      
      version.saved_by.should == users(:admin)
    end
  end
  
  describe "#diff" do
    it "should return a hash" do
      version = pages(:page_with_draft).versions.current
      version.diff.is_a?(Hash)
    end
    
    it "should not show a change on first version when it differs from current version" do
      page = pages(:published)
      page.title = "Changed"
      page.save
      version = page.versions.first
      version.diff.should_not include(:title)
    end
    
    it "should include a title change" do
      page = pages(:published)
      page.title = "Changed"
      page.save
      version = page.versions.current
      version.diff.should include(:title)
      version.diff[:title].should == ["Published", "Changed"]
    end
    
    it "should include a slug change" do
      page = pages(:published)
      page.slug = "changed"
      page.save
      version = page.versions.current
      version.diff.should include(:slug)
      version.diff[:slug].should == ["published", "changed"]
    end
    
    it "should include a part that stays the same" do
      page = pages(:published)
      page.parts_attributes = [page.parts.first.attributes]
      page.save
      version = page.versions.current
      version.diff.should include(:parts)
      version.diff[:parts].should include([{"name"=>"body", "filter_id"=>"", "content"=>"Published body."}])
    end
    
    it "should include a part addition" do
      page = pages(:published)
      page.parts_attributes = [page.parts.first.attributes, {"name"=>"added", "filter_id"=>"", "content"=>"I added this part"}]
      page.save
      version = page.versions.current
      version.diff.should include(:parts)
      version.diff[:parts].should include([nil, {"name"=>"added", "filter_id"=>"", "content"=>"I added this part"}])
    end
    
    it "should have its part stay the same when looking at the first version of a page that changed" do
      page = pages(:published)
      page.parts_attributes = [page.parts.first.attributes.merge("content" => "Changed body.")]
      page.save
      version = page.versions.first
      version.diff.should include(:parts)
      version.diff[:parts].should == [[{"name"=>"body", "filter_id"=>"", "content"=>"Published body."}]]
    end
    
    it "should include a part change" do
      page = pages(:published)
      page.parts_attributes = [page.parts.first.attributes.merge("content" => "Changed body.")]
      page.save
      version = page.versions.current
      version.diff.should include(:parts)
      version.diff[:parts].should == [[{"name"=>"body", "filter_id"=>"", "content"=>"Published body."}, {"name"=>"body", "filter_id"=>"", "content"=>"Changed body"}]]
    end
    
    it "should include a part deletion" do
      page = pages(:published)
      page.parts_attributes = [page.parts.first.attributes.merge("_delete" => "true")]
      page.save
      version = page.versions.current
      version.diff.should include(:parts)
      version.diff[:parts].should include([{"name"=>"body", "filter_id"=>"", "content"=>"Published body."},nil])
    end
    
  end
  
end