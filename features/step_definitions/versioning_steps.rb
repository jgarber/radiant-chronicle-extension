require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I have a (.*page.*)$/ do |status|
  case status
  when /published/
    @page = pages(:first)
    @page.status.should == Status[:published]
  when /draft/
    @page = pages(:draft)
    @page.status.should == Status[:draft]
  end
end

When /^I edit the page$/ do
  visit login_path
  fill_in("Username", :with => "admin")
  fill_in("Password",  :with => "password")
  click_button "Login"
  
  visit admin_pages_path
  click_link @page.title
end

When /^I save it as (?:a)?(draft|published)$/ do |status|
  select status.titleize, :from => "Status"
  click_button "Save"
end

Then /^the page should be saved$/ do
  @page.versions.size.should == 1
  @page.current.updated_at.should be_close(Time.now, 10.seconds)
end

Then /^not change the live version$/ do
  @page.reload.updated_at.should_not == @page.current.updated_at #FIXME: a better way to do this?
end

Then /^change the live version$/ do
  @page.reload.updated_at.should == @page.current.updated_at #FIXME: a better way to do this?
end
