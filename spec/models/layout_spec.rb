require File.dirname(__FILE__) + '/../spec_helper'

describe Layout do
  dataset :layouts
  
  it "should have one version when first created" do
    @layout = Layout.create :name => "versioned", :content => "I am versioned.", :status_id => Status[:draft].id
    @layout.should have(1).versions
  end

  it "should create a new version when saved" do
    @layout = layouts(:main)
    @layout.content = "foobar"
    @layout.status_id = Status[:draft].id

    lambda { @layout.save! }.should create_new_version
  end

  describe "drafts" do
    before :each do
      @layout = Layout.create(:name => "versioned", :content => "I am versioned.", :status_id => Status[:published].id)
      @layout.status_id = Status[:draft].id
    end

    it "should not change the live version when saved as a draft" do
      @layout.name = "foobarbaz"
      lambda { @layout.save! }.should create_new_version

      @layout.reload
      @layout.name.should == "versioned"
      @layout.status_id.should_not == Status[:draft].id
    end

    it "should properly save the draft version" do
      @layout.content = "foobar"
      lambda { @layout.save! }.should create_new_version

      @layout.reload
      @layout.current.content.should == "foobar"
      @layout.current.status_id.should == Status[:draft].id
    end

    it "should find the current live version" do
      @layout.current_live.should == @layout.reload
    end
  end

  describe "diff" do
    before :each do
      @layout = layouts(:main)
    end

    it "should include the name" do
      @layout.name = "Primo"
      @layout.diff.should include(:name)
      @layout.diff[:name].should == ["Main", "Primo"]
    end

    it "should include the content" do
      @layout.content = "Primo"
      @layout.diff.should include(:content)
      @layout.diff[:content].should == [<<-CONTENT, "Primo"]
<html>
  <head>
    <title><r:title /></title>
  </head>
  <body>
    <r:content />
  </body>
</html>
    CONTENT
    end

    it "should include the content type" do
      @layout.content_type = "text/css"
      @layout.diff.should include(:content_type)
      @layout.diff[:content_type].should == [nil, "text/css"]
    end

    it "should include the status change" do
      @layout = Layout.create(:name => "versioned", :content => "I am versioned.", :status_id => Status[:published].id)
      @layout.status_id = Status[:draft].id
      @layout.diff.should include(:status_id)
      @layout.diff[:status_id].should == [Status[:published].id, Status[:draft].id]
    end
  end

  def create_new_version
    change{ @layout.versions.size }.by(1)
  end
end