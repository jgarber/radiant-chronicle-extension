require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::PreviewHelper do
  dataset :versions
  
  describe "#site_preview_url" do
    it "should return the live URL for a page" do
      page = pages(:published)
      helper.site_preview_url(:live, page).should == "http://test.host/published/"
    end

    it "should return the dev URL for a page" do
      page = pages(:published)
      helper.site_preview_url(:dev, page).should == "http://dev.test.host/published/"
    end
    
    describe "when slug changes in a draft" do
      before(:each) do
        @page = pages(:published)
        @page.status = Status[:draft]
        @page.slug = "changed"
        @page.save
        @page.reload
      end
      
      it "should use the changed slug in dev mode" do
        helper.site_preview_url(:dev, @page).should == "http://dev.test.host/changed/"
      end
      
      it "should not use the changed slug in live mode" do
        helper.site_preview_url(:live, @page).should == "http://test.host/published/"
      end
      
    end
  
    describe "with custom hostnames" do
      before(:each) do
        Radiant::Config['dev.host'] = 'preview.mydomain.com'
        Radiant::Config['live.host'] = 'cms.mydomain.com'
      end
    
      it "should return the live URL for a page" do
        page = pages(:published)
        helper.site_preview_url(:live, page).should == "http://cms.mydomain.com/published/"
      end
    
      it "should return the dev URL for a page" do
        page = pages(:published)
        helper.site_preview_url(:dev, page).should == "http://preview.mydomain.com/published/"
      end
    end
  
    describe "with port number" do
      it "should return the live URL for a page" do
        @controller.request.port = 8080
        page = pages(:published)
        helper.site_preview_url(:live, page).should == "http://test.host:8080/published/"
      end
    end
  end
end