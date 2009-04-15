module Admin::TimelineHelper
  def timeline(page)
    versions = page.versions
    content_tag(:div, :id=>"timeline") do
      content_tag(:ol) do
        page.versions.collect do |version|
          version_id = "version-#{version.number}"
          content_tag(:li, :id => version_id) do
            tags = []
            tags << tag(:img, :id=>"#{version_id}-icon", :src=>"/images/admin/#{version.instance.status.name.downcase}.png")
            if (version.instance.status_id < Status[:published].id) && version.current?
              tags << tag(:img, :class=>"marker", :id=>"dev-marker",   :src=>"/images/admin/dev.png")
            else
              if version.current?
                tags << tag(:img, :class=>"marker", :id=>"dev-and-live-marker",   :src=>"/images/admin/dev-and-live.png")
              elsif version.current_live?
                tags << tag(:img, :class=>"marker", :id=>"live-marker",   :src=>"/images/admin/live.png")
              end
            end
            tags.join
          end
        end.join
      end
    end
  end
end
