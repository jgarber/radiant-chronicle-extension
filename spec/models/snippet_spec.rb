require File.dirname(__FILE__) + '/../spec_helper'

describe Snippet do
  dataset :snippets

  it "should have one version when first created" do
    @snippet = Snippet.create :name => "versioned", :content => "I am versioned.", :status_id => Status[:draft].id
    @snippet.should have(1).versions
  end

  it "should create a new version when saved" do
    @snippet = snippets(:first)
    @snippet.content = "foobar"
    @snippet.status_id = Status[:draft].id

    lambda { @snippet.save! }.should create_new_version
  end

  describe "drafts" do
    before :each do
      @snippet = Snippet.create(:name => "versioned", :content => "I am versioned.", :status_id => Status[:published].id)
      @snippet.status_id = Status[:draft].id
    end

    it "should not change the live version when saved as a draft" do
      @snippet.name = "foobarbaz"
      lambda { @snippet.save! }.should create_new_version

      @snippet.reload
      @snippet.name.should == "versioned"
      @snippet.status_id.should_not == Status[:draft].id
    end

    it "should properly save the draft version" do
      @snippet.content = "foobar"
      lambda { @snippet.save! }.should create_new_version

      @snippet.reload
      @snippet.current.content.should == "foobar"
      @snippet.current.status_id.should == Status[:draft].id
    end

    it "should find the current live version" do
      @snippet.current_live.should == @snippet.reload
    end
  end

  describe "diff" do
    before :each do
      @snippet = snippets(:first)
    end

    it "should include the name" do
      @snippet.name = "Primo"
      @snippet.diff.should include(:name)
      @snippet.diff[:name].should == ["first", "Primo"]
    end

    it "should include the content" do
      @snippet.content = "Primo"
      @snippet.diff.should include(:content)
      @snippet.diff[:content].should == ["test", "Primo"]
    end

    it "should include the filter_id" do
      @snippet.filter_id = "Textile"
      @snippet.diff.should include(:filter_id)
      @snippet.diff[:filter_id].should == [nil, "Textile"]
    end

    it "should include the status change" do
      @snippet = Snippet.create(:name => "versioned", :content => "I am versioned.", :status_id => Status[:published].id)
      @snippet.status_id = Status[:draft].id
      @snippet.diff.should include(:status_id)
      @snippet.diff[:status_id].should == [Status[:published].id, Status[:draft].id]
    end
  end

  def create_new_version
    change{ @snippet.versions.size }.by(1)
  end
end