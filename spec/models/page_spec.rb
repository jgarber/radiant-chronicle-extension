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
    @page.should have(1).versions
  end
  
  it "should instantiate an instance including parts uniformly" do
    @page = pages(:first)
    @page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"I changed the body!"}]
    @page.save
    
    @page.versions.current.instance.should == @page.versions.current.instance
  end
  
  it "should save versions when updated" do
    @page = Page.create(page_params)
    @page.title = "Change the title"
    
    lambda { 
      @page.save.should == true
    }.should create_new_version
    
    @page.versions.current.instance.should == @page
  end

  it "should save slug in the versions table" do
    @page = Page.create(page_params)
    @page.slug = "my-page"
    @page.save
    
    @page.versions.current.slug.should == @page.slug
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
      @page.versions.current.instance.title.should == "This is just a draft"
      @page.versions.current.instance.status_id.should == Status[:draft].id
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
      @page.versions.current.instance.parts.first.content.should == "I changed the body!"
      @page.versions.current.instance.status_id.should == Status[:draft].id
    end
  end

  describe "#find_by_url" do
    dataset :pages, :file_not_found
    
    before :each do
      @page = pages(:home)
    end
    
    it "should find a first-version draft in dev mode" do
      draft_page = @page.find_by_url('/draft/', false)
      draft_page.should == pages(:draft)
      draft_page.should have(0).versions
    end
    
    it 'should not find a first-version draft in live mode' do
      @page.find_by_url('/draft/').should == pages(:file_not_found)
    end
    
    it "should find a second-version draft in dev mode" do
      page = pages(:another)
      page.title = "Draft of Another"
      page.status = Status[:draft]
      page.save
      page.should have(1).versions
      page.reload
      @draft = page.versions.current.instance
      
      @page.find_by_url('/another/', false).should == @draft
    end
    
    it 'should not find a second-version draft in live mode' do
      page = pages(:another)
      page.title = "Draft of Another"
      page.status = Status[:draft]
      page.save
      page.should have(1).versions
      page.reload
      @draft = page.versions.current.instance
      
      @page.find_by_url('/another/', false).should == pages(:another)
    end

    
  end
  
  def create_new_version
    change{ @page.versions.length }.by(1)
  end
end
