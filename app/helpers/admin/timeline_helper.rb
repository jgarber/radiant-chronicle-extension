module Admin::TimelineHelper
  
  def page_edit_javascripts_with_timeline_bubbles
    page_edit_javascripts_without_timeline_bubbles + <<-CODE
    timeline_balloons = $A()
      function attach_help_balloon(version_number, data_url) {
        node = $('version-'+version_number+'-icon');
        timeline_balloons[version_number] = new HelpBalloon({
          dataURL: data_url,
          icon: node,
          balloonPrefix: '/images/admin/balloon-',
          button: '/images/admin/button.png',
          contentMargin: 40,
          showEffect: Effect.Appear,
          hideEffect: Effect.Fade,
          autoHideTimeout: 2000
        });
      }
      function load_version_diff(url, diff_link) {
        popup = $('version-diff-popup');
        new Effect.Highlight(diff_link);
        req = new Ajax.Request(url, { method: 'get', evalScripts: true });
        return false;
      }
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
      tags << version_tooltip(version)
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
    end + this_version_tooltip
  end
  
  def version_tooltip(version)
    data_url = admin_version_path(version)
    javascript_tag "attach_help_balloon(#{version.number}, '#{data_url}');"
  end
  
  def this_version_tooltip
    node = "$('this-icon')";
    javascript_tag <<-CODE
      new HelpBalloon({
        content: "You are currently editing this version.",
        icon: #{node},
        balloonPrefix: '/images/admin/balloon-',
        button: '/images/admin/button.png',
        contentMargin: 40,
        showEffect: Effect.Appear,
        hideEffect: Effect.Fade,
        autoHideTimeout: 2000
      });
    CODE
  end
end
