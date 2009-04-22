require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::VersionsController do
  dataset :versions, :users
  
  before :each do
    login_as :developer
  end
  
  describe "GET 'show'" do
    it " should be successful" do
      get 'show', :id => pages(:published).versions.first.id
      response.should be_success
      response.layout.should be_nil
    end
  end
end
