# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class ChronicleExtension < Radiant::Extension
  version "1.0"
  description "Keeps historical versions of pages and allows drafts of published pages."
  url "http://github.com/jgarber/radiant-chronicle-extension/"
  
  ::MAX_VERSIONS_VISIBLE_IN_TIMELINE = 14
  
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :versions, :member => { :diff => :get, :summary => :get }
    end
  end
  
  def activate
    require 'chronicle/diff'
    ActiveRecord::Base::VersionsProxyMethods.send :include, Chronicle::VersionsProxyMethods
    Version.send :include, Chronicle::VersionExtensions
    Page.send :include, Chronicle::PageExtensions
    PagePart.send :include, Chronicle::PagePartExtensions
    Admin::ResourceController.send :include, Chronicle::ResourceControllerExtensions
    admin.page.edit.add :main, "admin/timeline", :before => "edit_header"
    Admin::PagesController.send :include, Chronicle::Interface
    Admin::PagesController.send :include, Chronicle::PagesControllerExtensions
    admin.page.edit.add :popups, 'admin/pages/version_diff_popup'
    admin.page.edit.add :form_bottom, 'view_page_after_save'
    admin.page.edit.add :main, 'open_preview_window'
    admin.page.index.add :sitemap_head, 'open_preview_window'
    
    admin.tabs.add "History", "/admin/versions/", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Chronicle"
  end
  
end
