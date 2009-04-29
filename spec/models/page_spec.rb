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
    
    @page.current.should == @page.current
  end
  
  it "should save versions when updated" do
    @page = Page.create(page_params)
    @page.title = "Change the title"
    
    lambda { 
      @page.save.should == true
    }.should create_new_version
    
    @page.current.should == @page
  end
  
  it "should properly save a version when Page is updated as published" do
    @page = pages(:first)
    @page.title = "New version"
  
    lambda { 
      @page.save.should == true
    }.should create_new_version
  
    @page.reload
    @page.current.should == @page
    @page.title.should == "New version"
  end
  
  it "should change the live version when PagePart is updated for a published page" do
    @page = pages(:first)
    @page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"I changed the body!"}]
  
    lambda { 
      @page.save.should == true
    }.should create_new_version
  
    @page.reload
    @page.parts(true).first.content.should == "I changed the body!"
    @page.current.should == @page
    @page.current.parts.first.content.should == "I changed the body!"
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
      @page.current.title.should == "This is just a draft"
      @page.current.status_id.should == Status[:draft].id
    end
    
    it "should not change the live version when PagePart is updated as a draft" do
      @page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"I changed the body!"}]
    
      lambda { 
        @page.save.should == true
      }.should create_new_version
    
      @page.reload
      @page.status_id.should_not == Status[:draft].id
      @page.parts(true).first.content.should_not == "I changed the body!"
    end
  
    it "should properly save a version when a part is updated as a draft" do
      @page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"I changed the body!"}]
    
      lambda { 
        @page.save.should == true
      }.should create_new_version
    
      @page.reload
      @page.current.parts.first.content.should == "I changed the body!"
      @page.current.status_id.should == Status[:draft].id
    end
    
    it "should properly save a version and make it live when a part is updated as published" do
      @page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"I changed the body!"}]
      @page.save
      
      draft = @page.current
      draft.status_id = Status[:published].id
      content = "Now it's published"
      draft.parts = [{"name"=>"body", "filter_id"=>"", "content"=>content}]
      lambda {
        draft.save.should == true
      }.should create_new_version
      
      @page.reload
      @page.current.parts.first.content.should == content
      @page.parts.first.content.should == content
      @page.current.status_id.should == Status[:published].id
      @page.status_id.should == Status[:published].id
    end
    
    
    it "should have a draft of the child in #current_children" do
      @page.save
      
      pages(:home).current_children.should include(@page)
    end
  end
  
  describe "#diff" do
    it "should include a title change" do
      page = pages(:home)
      page.title = "Changed"
      page.diff.should include("title")
      page.diff["title"].should == ["Home", "Changed"]
    end
    
    it "should include a slug change" do
      page = pages(:first)
      page.slug = "changed"
      page.diff.should include("slug")
      page.diff["slug"].should == ["first", "changed"]
    end
    
    it "should include a part that stays the same" do
      page = pages(:first)
      page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"First body."}]
      page.diff.should include("parts")
      page.diff["parts"].should include([{"name"=>"body", "filter_id"=>"", "content"=>"First body."}])
    end
    
    it "should include a part addition" do
      page = pages(:first)
      page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"First body."}, {"name"=>"added", "filter_id"=>"", "content"=>"I added this part"}]
      page.diff.should include("parts")
      page.diff["parts"].should include([nil, {"name"=>"added", "filter_id"=>"", "content"=>"I added this part"}])
    end
    
    it "should include a part change" do
      page = pages(:first)
      page.parts = [{"name"=>"body", "filter_id"=>"", "content"=>"Changed body"}]
      page.diff.should include("parts")
      page.diff["parts"].should == [[{"name"=>"body", "filter_id"=>"", "content"=>"First body."}, {"name"=>"body", "filter_id"=>"", "content"=>"Changed body"}]]
    end
    
    it "should include a part deletion" do
      page = pages(:first)
      page.parts = [{"name"=>"added", "filter_id"=>"", "content"=>"I added this part"}]
      page.diff.should include("parts")
      page.diff["parts"].should include([{"name"=>"body", "filter_id"=>"", "content"=>"First body."},nil])
    end
  end

  describe "#find_by_url" do
    dataset :pages, :file_not_found
    
    before :each do
      @home = pages(:home)
      @page = pages(:another)
      @page.status = Status[:draft]
    end
    
    it "should find a first-version draft in dev mode" do
      draft_page = @home.find_by_url('/draft/', false)
      draft_page.should == pages(:draft)
      draft_page.should have(0).versions
    end
    
    it 'should not find a first-version draft in live mode' do
      @home.find_by_url('/draft/').should == pages(:file_not_found)
    end
    
    it "should find a second-version draft in dev mode" do
      @page.title = "Draft of Another"
      lambda { @page.save }.should create_new_version
      @draft = @page.current
      
      @home.find_by_url('/another/', false).should == @draft
    end
    
    it 'should not find a second-version draft in live mode' do
      @page.title = "Draft of Another"
      @page.save
      @draft = @page.current
      
      @home.find_by_url('/another/', false).should == pages(:another)
    end
    
    it "should find the draft version of a FileNotFound page when in dev mode" do
      pages(:draft_file_not_found).destroy # This is a different kind of draft
      
      page = pages(:file_not_found)
      page.title = "What are you looking 404?"
      page.status = Status[:draft]
      page.save
      
      @home.find_by_url('/nothing-doing/').should == pages(:file_not_found)
      @home.find_by_url('/nothing-doing/', false).title.should == "What are you looking 404?"
    end
    
    describe "when changed slug in draft" do
      before(:each) do
        parent = pages(:parent)
        parent.slug = "parent-draft"
        parent.status = Status[:draft]
        parent.save
        @parent_draft = parent.current
        @parent_draft.slug.should == "parent-draft"
      end
      
      it "should find the page at the new slug in dev mode" do
        @home.find_by_url('/parent-draft/', false).should == @parent_draft
      end

      it "should not find the page at the old slug in dev mode" do
        @home.find_by_url('/parent/', false).should == pages(:draft_file_not_found)
      end
      
      it "should find the published child at the new url in dev mode" do
        @home.find_by_url('/parent-draft/child/', false).should == pages(:child)
      end

      it "should not find the published child at the old url in dev mode" do
        @home.find_by_url('/parent/child/', false).should == pages(:draft_file_not_found)
      end
      
      it "should not find the published child at the new url in live mode" do
        @home.find_by_url('/parent-draft/child/').should == pages(:file_not_found)
      end
      
      it "should find the published child at the old url in live mode" do
        @home.find_by_url('/parent/child/').should == pages(:child)
      end
      
      describe "and child also has a draft version" do
        before(:each) do
          child = pages(:child)
          child.title = "Child draft"
          child.status = Status[:draft]
          child.save
          @child_draft = child.current
          @child_draft.title.should == "Child draft"
        end
        
        it "should find the draft child at the new url in dev mode" do
          @home.find_by_url('/parent-draft/child/', false).should == @child_draft
        end
      
        it "should find the published child at the old url in live mode" do
          @home.find_by_url('/parent/child/').should == pages(:child)
        end
      end
      
    end
    
  end
  
  def create_new_version
    change{ @page.versions.size }.by(1)
  end
end
