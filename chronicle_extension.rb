# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class ChronicleExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/chronicle"
  
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :versions, :member => { :diff => :get }
    end
  end
  
  def activate
    Version.send :include, Chronicle::VersionExtensions
    Page.send :include, Chronicle::PageExtensions
    Admin::ResourceController.send :include, Chronicle::ResourceControllerExtensions
    admin.page.edit.add :main, "admin/timeline", :before => "edit_header"
    Admin::PagesController.send :include, Chronicle::Interface
    admin.page.edit.add :popups, 'admin/pages/version_diff_popup'
    
    # admin.tabs.add "Chronicle", "/admin/chronicle", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Chronicle"
  end
  
end
