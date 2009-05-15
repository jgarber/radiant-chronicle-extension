require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am looking at a timeline that has a (dev|live) marker$/ do |type|
  Given "I have a published page with a draft"
  visit admin_version_path(@page.versions.current)
  response.should have_selector("a img##{type}-marker")
end

Given /^I am looking at a timeline that has a dev-and-live marker$/ do
  @page = pages(:first)
  @page.status.should == Status[:published]
  @page.save
  @page.reload
  visit admin_version_path(@page.versions.current)
  response.should have_selector("a img#dev-and-live-marker")end

When /^I click the (dev|live|dev-and-live) marker$/ do |type|
  click_link "#{type}-marker"
end

Then /^I should be taken to the page in live mode$/ do
  @controller.request.url.should == "http://www.example.com/first/"
end

Then /^I should be taken to the page in dev mode$/ do
  @controller.request.url.should == "http://dev.www.example.com/first/"
end

Given /^I am editing a page with a draft$/ do
  Given "I have a published page with a draft"
  visit edit_admin_page_path(@page)
end

Given /^I am editing a published page$/ do
  Given "I have a published page"
  visit edit_admin_page_path(@page)
end

Given /^I changed the status to (.*)$/ do |status|
  select status.titleize, :from => "Status"
end

Then /^the page should open on the dev site$/ do
  response.should contain("window.open")
end

Then /^the "([^\"]*)" box should remain checked for next time\.$/ do |field_label|
  field_labeled(field_label).should be_checked
end

