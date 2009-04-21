module Admin::TimelineHelper
  
  def page_edit_javascripts_with_timeline_bubbles
    page_edit_javascripts_without_timeline_bubbles + <<-CODE
      function attach_help_bubbles_to_timeline_nodes(timeline) {
        timeline.select('img.timeline-icon').each(function(node) {
          new HelpBalloon({
            dataURL: '#{formatted_admin_version_path(:format => 'xml', :id => 1)}',
            icon: node,
            balloonPrefix: '/images/admin/balloon-',
            button: '/images/admin/button.png',
            contentMargin: 40,
            autoHideTimeout: 2000,
            showEffect: Effect.Appear,
            hideEffect: Effect.Fade
          });
        });
      }
      document.observe("dom:loaded", function() {
        attach_help_bubbles_to_timeline_nodes($('timeline'));
      });
    CODE
  end
  
  def timeline(page)
    versions = page.versions
    content_tag(:div, :id=>"timeline") do
      content_tag(:ol) do
        this_version_node +
        page.versions.collect do |version|
          version_node(version)
        end.join
      end
    end
  end
  
  def version_node(version)
    content_tag(:li, :id => "version-#{version.number}") do
      tags = [ version_icon(version) ]
      case
      when version.only_visible_in_dev_mode? && version.current?
        tags << marker(:dev)
      when version.current?
        tags << marker("dev-and-live")
      when version.current_live?
        tags << marker(:live)
      end
      tags.join
    end
    
  end
  
  def marker(type)
    type = type.to_s
    tag(:img, :class=>"marker", :id=>"#{type}-marker",   :src=>"/images/admin/#{type}.png")
  end
  
  def version_icon(version)
    tag(:img, :id=>"version-#{version.number}-icon", :src=>"/images/admin/#{version.instance.status.name.downcase}.png", :class=>"timeline-icon")
  end
  
  def this_version_node
    content_tag(:li, :id => "this") do
      tag(:img, :id=>"this-icon", :src=>"/images/admin/this.png", :class=>"timeline-icon")
    end
  end
end
