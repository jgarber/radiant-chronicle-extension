require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::VersionsController do
  dataset :versions, :users
  
  before :each do
    login_as :developer
  end
  
  describe "GET 'index'" do
    it " should be successful" do
      get 'index'
      response.should be_success
    end
    
    it "should have some versions" do
      get 'index'
      assigns['versions'].should_not be_nil
    end
    
    describe "pagination" do
      before do
        @page = pages(:published)
        100.times do |i|
          @page.title = i
          @page.save
        end
      end
      
      it "should paginate" do
        get 'index'
        assigns['versions'].size.should == 30
      end

      it "should paginate according to config" do
        Radiant::Config['chronicle.history.per_page'] = 50
        get 'index'
        assigns['versions'].size.should == 50
      end
    end
  end

  describe "GET 'show'" do
    it " should be successful" do
      get 'show', :id => pages(:published).versions.first.id
      response.should be_success
    end
  end
  
  describe "GET 'summary'" do
    it " should be successful" do
      get 'summary', :id => pages(:published).versions.first.id
      response.should be_success
      response.layout.should be_nil
    end
  end
  
  describe "GET 'diff'" do
    it " should be successful" do
      get 'diff', :id => pages(:published).versions.first.id
      response.should be_success
      response.layout.should be_nil
    end
  end
end
