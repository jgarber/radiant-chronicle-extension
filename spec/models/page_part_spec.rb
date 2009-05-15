require File.dirname(__FILE__) + '/../spec_helper'

describe PagePart do
  dataset :pages
  
  describe "#attributes_for_diff" do
    before(:each) do
      @page_part = PagePart.create(:content => "Body", :name => "body", :filter_id => "Textile")
    end
    
    it "should exclude the id attribute" do
      @page_part.id.should_not be_blank
      @page_part.attributes_for_diff.keys.should_not include("id")
    end
    
    it "should exclude the page_id attribute" do
      page_part = pages(:first).parts.first
      page_part.page_id.should_not be_blank
      page_part.attributes_for_diff.keys.should_not include("page_id")
    end
    
    it "should include the name" do
      @page_part.attributes_for_diff["name"].should == "body"
    end
    
    it "should include the content" do
      @page_part.attributes_for_diff["content"].should == "Body"
    end

    it 'should replace \r\n with \n in the content' do
      @page_part.content = "Body\r\ntext"
      @page_part.attributes_for_diff["content"].should == "Body\ntext"
    end
    
    it "should include the filter_id" do
      @page_part.attributes_for_diff["filter_id"].should == "Textile"
    end
    
    it "should have a blank filter_id if it is nil" do
      @page_part = PagePart.create(:content => "Body", :name => "body", :filter_id => nil)
      @page_part.attributes_for_diff["filter_id"].should == ""
    end
  end
end