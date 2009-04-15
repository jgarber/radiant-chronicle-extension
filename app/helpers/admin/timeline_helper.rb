module Admin::TimelineHelper
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
    tag(:img, :id=>"version-#{version.number}-icon", :src=>"/images/admin/#{version.instance.status.name.downcase}.png")
  end
  
  def this_version_node
    content_tag(:li, :id => "this") do
      tag(:img, :id=>"this-icon", :src=>"/images/admin/this.png")
    end
  end
end
