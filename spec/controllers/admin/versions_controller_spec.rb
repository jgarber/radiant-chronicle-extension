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
