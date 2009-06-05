require File.dirname(__FILE__) + '/../../spec_helper'

describe "/admin/_timeline.html.haml" do
  dataset :versions
  
  before(:each) do
    template.send :extend, Admin::TimelineHelper
    class << template
      def model
        @page
      end
    end
  end
  
  describe "when used in the context of a page" do
    it "should have a node for the working version, which I am currently editing" do
      assigns[:page] = pages(:draft)
      render 'admin/_timeline.html.haml'
      response.should have_selector("li", :id=>"working-version") do |li|
        li.should have_marker(:this)
      end
    end
    
    it "should attach the javascript help balloons" do
      response.should_not contain("attach_help_balloon")
    end
  end
  
  describe "when used in the context of a version" do
    before(:each) do
      assigns[:version] = pages(:draft).versions.current
      assigns[:page] = pages(:draft)
      render 'admin/_timeline.html.haml'
    end

    it "should have a chevron on the version I am currently viewing" do
      response.should have_selector("li", :id=>"version-1") do |li|
        li.should have_marker(:this)
      end
    end
    
    it "should not have a working version node" do
      response.should_not have_selector("li", :id=>"working-version")
    end
    
    it "should have links to other versions" do
      response.should have_selector("li", :id=>"version-1") do |li|
        li.should have_selector("a", :href => "/admin/versions/#{assigns[:version].id}")
      end
    end
    
    it "should not attach javascript help balloons" do
      response.should_not contain("attach_help_balloon")
    end
  end
  
  
  it "should produce a dev flag on a first-version draft" do
    assigns[:page] = pages(:draft)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:draft) do |li|
      li.should have_marker(:dev)
    end
  end

  it "should produce a dev flag on a first-version reviewed page" do
    assigns[:page] = pages(:reviewed)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:reviewed) do |li|
      li.should have_marker(:dev)
    end
  end

  it "should produce a dev+live flag on a first-version hidden page" do
    assigns[:page] = pages(:hidden)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:hidden) do |li|
      li.should have_marker("dev-and-live")
    end
  end

  it "should produce a live flag on live version of published page with draft" do
    assigns[:page] = pages(:page_with_draft)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:published) do |li|
      li.should have_marker(:live)
    end
  end
  
  it "should produce a dev flag on current version of published page with draft" do
    assigns[:page] = pages(:page_with_draft)
    render 'admin/_timeline.html.haml'
    response.should have_version(2).as(:draft) do |li|
      li.should have_marker(:dev)
    end
  end
  
  it "should produce a live+dev flag on a current published page" do
    assigns[:page] = pages(:published)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:published) do |li|
      li.should have_marker("dev-and-live")
    end
  end
  
  it "should not put a marker on a published version that is not current live" do
    assigns[:page] = pages(:published_with_many_versions)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:published) do |li|
      li.should_not have_marker
    end
  end
  
  it "should not put a marker on a draft version that is not current dev" do
    assigns[:page] = pages(:draft_with_many_versions)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:draft) do |li|
      li.should_not have_marker
    end
  end
  
  it "should make the line fade out when the timeline does not begin with version 1" do
    page = pages(:draft_with_many_versions)
    20.times do
      page.save
    end
    page.versions.size.should > MAX_VERSIONS_VISIBLE_IN_TIMELINE
    expected_version_number = page.versions_with_limit(MAX_VERSIONS_VISIBLE_IN_TIMELINE).last.number
    assigns[:page] = page
    render 'admin/_timeline.html.haml'
    response.should have_selector("li", :class => "beginning", :id => "version-#{expected_version_number}")
  end
  
  def have_marker(type=nil)
    opts = {:class=>"marker"}
    if type
      type = type.to_s
      opts.merge! :id=>"#{type}-marker"
    end
    have_selector("img", opts) # Works only with the monkey patch below
  end
  
end

# Monkey patch for https://webrat.lighthouseapp.com/projects/10503/tickets/234-have_selector-and-have_xpath-dont-match-descendants-in-blocks
# Without it, img inside a fails to match
module Webrat
  module Matchers
    
    class HaveXpath #:nodoc:
      def rexml_matches(stringlike)
        if REXML::Node === stringlike || Array === stringlike
          @query = query.map { |q| q.gsub(%r'^//', './/') }
        else
          @query = query
        end

        add_options_conditions_to(@query)

        @document = Webrat.rexml_document(stringlike)

        @query.map do |q|
          if @document.is_a?(Array)
            @document.map { |d| REXML::XPath.match(d, q) }
          else
            REXML::XPath.match(@document, q)
          end
        end.flatten.compact
      end
    
      def nokogiri_matches(stringlike)
        if Nokogiri::XML::NodeSet === stringlike
          @query = query.gsub(%r'^//', './/')
        else
          @query = query
        end
        
        add_options_conditions_to(@query)
        
        @document = Webrat::XML.document(stringlike)
        @document.xpath(*@query)
      end
      
    end
  end
end