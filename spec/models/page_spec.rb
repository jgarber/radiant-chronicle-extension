require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  dataset :pages, :layouts

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
    @page.parts_attributes = [@page.parts.first.attributes.merge("content" => "I changed the body!")]
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
    @page.parts_attributes = [@page.parts.first.attributes.merge("content" => "I changed the body!")]

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
  
  it "should allow an immediate move of a draft page" do
    @page = pages(:draft)
    @parent = pages(:parent)
    @page.update_attributes!(:parent_id => @parent.id)
    @page.reload
    @page.parent_id.should == @parent.id
    @page.current.parent_id.should == @parent.id
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
      @page.parts_attributes = [@page.parts.first.attributes.merge("content" => "I changed the body!")]

      # lambda {
      #   @page.save.should == true
      # }.should create_new_version
      
      @page.reload
      @page.status_id.should_not == Status[:draft].id
      @page.parts(true).first.content.should_not == "I changed the body!"
    end

    it "should properly save a version when a part is updated as a draft" do
      @page.parts_attributes = [@page.parts.first.attributes.merge("content" => "I changed the body!")]

      lambda {
        @page.save.should == true
      }.should create_new_version

      @page.reload
      @page.current.parts.first.content.should == "I changed the body!"
      @page.current.status_id.should == Status[:draft].id
    end

    it "should properly save a version and make it live when a part is updated as published" do
      @page.parts_attributes = [@page.parts.first.attributes.merge("content" => "I changed the body!")]
      @page.save

      draft = @page.current
      draft.status_id = Status[:published].id
      content = "Now it's published"
      draft.parts_attributes = [draft.parts.first.attributes.merge("content" => content)]
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
      page.diff.should include(:title)
      page.diff[:title].should == ["Home", "Changed"]
    end

    it "should include a slug change" do
      page = pages(:first)
      page.slug = "changed"
      page.diff.should include(:slug)
      page.diff[:slug].should == ["first", "changed"]
    end

    it "should include a layout change" do
      page = pages(:first)
      page.layout_id = layout_id(:main)
      page.diff.should include(:layout_id)
      page.diff[:layout_id].should == [nil, layout_id(:main)]
    end

    it "should include a page type change" do
      page = pages(:first)
      page.class_name = "ArchivePage"
      page.diff.should include(:class_name)
      page.diff[:class_name].should == [nil, "ArchivePage"]
    end

    it "should include a status change" do
      page = pages(:first)
      page.status_id = Status[:draft].id
      page.diff.should include(:status_id)
      page.diff[:status_id].should == [Status[:published].id, Status[:draft].id]
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

    it "should return nil when it cannot find the page or the FileNotFound page" do
      pages(:file_not_found).destroy
      pages(:draft_file_not_found).destroy

      @home.find_by_url('/nothing-doing/nada.jpg').should be_nil
      @home.find_by_url('/nothing-doing/nada.jpg', false).should be_nil
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

    describe "optimistic locking" do
      dataset :pages

      it "should prevent updating a stale page" do
        p1 = pages(:first)
        p2 = pages(:first)

        p1.title = "Changed"
        p1.save

        p2.title = "should fail"
        lambda {
          p2.save
        }.should raise_error(ActiveRecord::StaleObjectError)
      end

      it "should prevent updating a stale page that has a draft" do
        p1 = pages(:first)
        p2 = pages(:first)

        p1.title = "Changed"
        p1.status = Status[:draft]
        p1.save

        p2.title = "should fail"
        lambda {
          p2.save
        }.should raise_error(ActiveRecord::StaleObjectError)
      end

      it "should prevent updating a stale page as a draft" do
        p1 = pages(:first)
        p2 = pages(:first)

        p1.title = "Changed"
        p1.save

        p2.title = "should fail"
        p2.status = Status[:draft]
        lambda {
          p2.save
        }.should raise_error(ActiveRecord::StaleObjectError)
      end

    end
  end

  describe "tags" do
    dataset :snippets
    before :each do
      Snippet.update_all(:status_id => Status[:published].id)
      @page = pages(:first)
    end
    
    describe "<r:children:each />" do
      it "should retrieve current versions of children on the dev host" do
        @page = pages(:parent)
        @page.children.first.update_attributes(:slug => "kid", :status => Status[:draft])
        @page.should render('<r:children:each by="slug"><r:slug /> </r:children:each>').as('kid child-2 child-3 ').on('dev.site.com')
      end
    end
    
    describe "<r:find />" do
      it "should retrieve current versions of found pages on the dev host" do
        @page = pages(:parent)
        @page.children.first.update_attributes(:slug => "kid", :status => Status[:draft])
        @page.should render('<r:find url="/parent/kid"><r:slug /></r:find>').as('kid').on('dev.site.com')
      end
    end
    
    describe "<r:parent />" do
      it "should use the current version of the parent on the dev host" do
        @page = pages(:parent)
        @page.update_attributes(:slug => "parent-draft", :status => Status[:draft])
        pages(:child).should render('<r:parent><r:slug /></r:parent>').as('parent-draft').on('dev.site.com')
      end
    end
    
    describe "overriding <r:snippet />" do
      before :each do
        snippet = snippets(:first)
        snippet.save # Create a live version
        snippet.status.should == Status[:published]
        lambda { snippet.update_attributes(:content => "First dev", :status_id => Status[:draft].id) }.should change { snippet.versions.size }.by(1)
      end

      it "should render the published snippet in production mode" do
        @page.should render("<r:snippet name='first' />").as("test")
      end

      it "should render the draft snippet in dev mode" do
        @page.should render("<r:snippet name='first' />").as("First dev").on("dev.example.com")
      end

      it "should not render draft snippets in production mode" do
        snippet = Snippet.create(:name => "foo", :content => "bar", :status_id => Status[:draft].id)
        @page.should render("<r:snippet name='foo' />").with_error('snippet not found')
      end

      it "should not render nonexistent snippet in dev mode" do
        @page.should render("<r:snippet name='doesnotexist' />").on("dev.example.com").with_error('snippet not found')
      end
    
      describe "when snippet title changed in current draft" do
        before :each do
          snippet = snippets(:first)
          snippet.current.update_attributes(:name => "firstly", :status_id => Status[:draft].id)
          snippet.current.name.should == "firstly"
        end
      
        it "should render snippet with draft name in dev mode" do
          @page.should render("<r:snippet name='firstly' />").on("dev.example.com").as("First dev")
        end
      
        it "should not render snippet with original name in dev mode" do
          @page.should render("<r:snippet name='first' />").on("dev.example.com").with_error('snippet not found')
        end
      
        it "should not render snippet with draft name in live mode" do
          @page.should render("<r:snippet name='firstly' />").with_error('snippet not found')
        end
      
        it "should render snippet with original name in live mode" do
          @page.should render("<r:snippet name='first' />").as("test")
        end
      end
    end
  end

  describe "layouts dev mode" do
    dataset :pages_with_layouts
    before :each do
      Layout.update_all(:status_id => Status[:published].id)
      @page = pages(:first)
      @layout = layouts(:main)
      @layout.save # Create a live version
      @layout.status.should == Status[:published]
      lambda { @layout.update_attributes(:content => "<r:title />", :status_id => Status[:draft].id) }.should change { @layout.versions.size }.by(1)
      @layout.reload
    end

    it "should render the regular layout in production mode" do
      @page.should render_as("<html>\n  <head>\n    <title>First</title>\n  </head>\n  <body>\n    First body.\n  </body>\n</html>\n")
    end

    it "should render the draft layout in dev mode" do
      @page.should render_as("First").on("dev.example.com")
    end
  end

  def create_new_version
    change{ @page.versions.size }.by(1)
  end
end
