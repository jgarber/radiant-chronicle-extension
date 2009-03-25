require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  dataset :pages
  
  it "should be valid" do
    @page = Page.new(page_params)
    @page.should be_valid
  end
  
  it "should have one version when first created" do
    @page = Page.new(page_params)
    @page.save
    @page.versions.length.should == 1
  end
  
  it "should save versions when updated" do
    @page = Page.create(page_params)
    @page.title = "Change the title"
    
    lambda { 
      @page.save.should == true
    }.should create_new_version
    
    @page.versions.current.model.should == @page
    
  end
  
  it "should create a new draft in the main table" do
    @page = Page.create(page_params(:status_id => Status[:draft].id))
    @page.reload
    @page.status.should == Status[:draft]
  end
  
  describe "drafts" do
    before(:each) do
      @page = pages(:first)
      @page.status_id = Status[:draft].id
    end
    
    it "should not change the live version when Page is updated as a draft" do
      lambda { 
        @page.save.should == true
      }.should create_new_version
    
    
      @page.reload
      @page.status_id.should_not == Status[:draft].id
    end
  
    it "should properly save a version when Page is updated as a draft" do
      @page.title = "This is just a draft"
    
      lambda { 
        @page.save.should == true
      }.should create_new_version
    
      @page.reload
      @page.versions.current.model.title.should == "This is just a draft"
      @page.versions.current.model.status_id.should == Status[:draft].id
    end
  
    it "should not change the live version when PagePart is updated as a draft" do
      @page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"I changed the body!"}]
    
      lambda { 
        @page.save.should == true
      }.should create_new_version
    
      @page.reload
      @page.status_id.should_not == Status[:draft].id
      @page.parts.first.content.should_not == "I changed the body!"
    end
  
    it "should properly save a version when PagePart is updated as a draft" do
      @page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"I changed the body!"}]
    
      lambda { 
        @page.save.should == true
      }.should create_new_version
    
      @page.reload
      @page.versions.current.model.parts.first.content.should == "I changed the body!"
      @page.versions.current.model.status_id.should == Status[:draft].id
    end
  end

  def create_new_version
    change{ @page.versions.length }.by(1)
  end
end
