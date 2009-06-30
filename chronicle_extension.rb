# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'

class ChronicleExtension < Radiant::Extension
  version "2.0"
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
    ActiveRecord::Base::VersionsProxyMethods.class_eval { include Chronicle::VersionsProxyMethods }
    Version.class_eval { include Chronicle::VersionExtensions }
    Page.class_eval do 
      include Chronicle::PageExtensions
      include Chronicle::Tags
    end
    PagePart.class_eval { include Chronicle::PagePartExtensions }
    Snippet.class_eval { include Chronicle::SimpleModelExtensions }
    Layout.class_eval { include Chronicle::SimpleModelExtensions }

    Admin::ResourceController.class_eval { include Chronicle::ResourceControllerExtensions }
    Admin::PagesController.class_eval { include Chronicle::Interface }
    Admin::PagesController.class_eval { include Chronicle::PagesControllerExtensions }
    Admin::SnippetsController.class_eval { include Chronicle::Interface }
    Admin::LayoutsController.class_eval { include Chronicle::Interface }

    admin.page.edit.add :main, "admin/timeline", :before => "edit_header"
    admin.page.edit.add :main, 'admin/version_diff_popup'
    admin.page.edit.add :form_bottom, 'view_page_after_save'
    admin.page.edit.add :main, 'open_preview_window'
    admin.page.index.add :sitemap_head, 'open_preview_window'

    admin.snippet.edit.add :main, "admin/timeline", :before => "edit_header"
    admin.snippet.edit.add :main, 'admin/version_diff_popup'
    admin.snippet.edit.add :form, 'status_field', :before => 'edit_timestamp'
    admin.snippet.index.add :tbody, 'status_cell', :before => "modify_cell"
    admin.snippet.index.add :thead, 'status_header', :before => "modify_header"

    admin.layout.edit.add :main, "admin/timeline", :before => "edit_header"
    admin.layout.edit.add :main, 'admin/version_diff_popup'
    admin.layout.edit.add :form, 'status_field', :before => 'edit_timestamp'
    admin.layout.index.add :tbody, 'status_cell', :before => "modify_cell"
    admin.layout.index.add :thead, 'status_header', :before => "modify_header"

    admin.tabs.add "History", "/admin/versions/", :visibility => [:all]
  end

end
