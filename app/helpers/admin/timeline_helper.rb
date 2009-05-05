module Admin::TimelineHelper
  
  def marker_for_version(version)
    case
    when version.only_visible_in_dev_mode? && version.current?
      marker(:dev)
    when version.current?
      marker("dev-and-live")
    when version.current_live?
      marker(:live)
    end
  end
  
  def marker(type)
    type = type.to_s
    tag(:img, :class=>"marker", :id=>"#{type}-marker",   :src=>"/images/admin/#{type}.png")
  end
  
  def version_icon(version)
    icon = tag(:img, :id=>"version-#{version.number}-icon", :src=>"/images/admin/#{version.instance.status.name.downcase}.png", :class=>"timeline-icon")
    link_to icon, admin_version_path(version)
  end
  
  def working_version_node
    content_tag(:li, :id => "working-version") do
      tag(:img, :id=>"working-version-icon", :src=>"/images/admin/working.png", :class=>"timeline-icon") + 
      marker(:this)
    end + working_version_tooltip
  end
  
  def version_tooltip(version)
    data_url = summary_admin_version_path(version)
    javascript_tag "attach_help_balloon(#{version.number}, '#{data_url}');"
  end
  
  def working_version_tooltip
    node = "$('working-version-icon')";
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
