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
      
      it "should not use the changed slug in live mode even when given the draft" do
        helper.site_preview_url(:live, @page.current).should == "http://test.host/published/"
      end
      
      it "should use the changed slug + child's changed slug in dev mode" do
        @child = Page.create!(:title => "Child of published", :slug => "child-of-published", :breadcrumb => "Child of published", :parent => @page)
        @child.status = Status[:draft]
        @child.slug = "changed"
        @child.save
        @child.reload
        
        helper.site_preview_url(:dev, @child).should == "http://dev.test.host/changed/changed/"
      end
    end
  
    describe "with custom hostnames" do
      before(:each) do
        # Stub the live and dev hosts.  These get used all over, so
        # a message expectation doesn't work.
        Radiant::Config.stub!(:[]).and_return do |key|
          if key == 'dev.host' 
            "preview.mydomain.com"
          elsif key == 'live.host'
            "cms.mydomain.com"
          end
        end
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
    
    describe "with localhost" do
      it "should return the localhost URL instead of appending 'dev.'" do
        @controller.request.host = "localhost"
        @controller.request.port = 3000
        page = pages(:published)
        helper.site_preview_url(:dev, page).should == "http://localhost:3000/published/"
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