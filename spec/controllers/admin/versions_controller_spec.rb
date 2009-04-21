require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::VersionsController do
  dataset :versions

  it "GET 'show' should be successful" do
    get 'show', :id => pages(:published).versions.first.id
    response.should be_success
  end
end
