module Admin::TimelineHelper
  include Admin::PreviewHelper
  
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
    image_tag = image_tag("/images/admin/#{type}.png", :class=>"marker", :id=>"#{type}-marker")
    if version_model.is_a?(Page)
      case type
      when "live"
        link_to(image_tag, live_page_url(@page))
      when "dev"
        link_to(image_tag, dev_page_url(@page))
      when "dev-and-live"
        link_to(image_tag, dev_page_url(@page))
      else
        image_tag
      end
    else
      image_tag
    end
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
  
  def versions_for_timeline
    @versions_for_timeline ||= version_model.versions_with_limit(MAX_VERSIONS_VISIBLE_IN_TIMELINE)
  end
  
  def version_class(index)
    if (index+1) == versions_for_timeline.size
      "beginning"
    else
      ''
    end
  end
  
  def version_model
    (@version && @version.instance) || model
  end
end
