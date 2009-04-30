module Admin::VersionsHelper
  def field_diff(*array)
    array = array.first if array.first.is_a?(Array)
    if array.length > 1
      content_tag(:span, array[0], :class => "from") +
      " &rarr; " +
      content_tag(:span, array[1], :class => "to")
    else
      array.first
    end
  end
  
  def part_diff(array)
    previous, current = *array
    unique_parts = array.compact
    options = {:class => "page"}
    options[:class] += " added" if previous.nil?
    options[:class] += " deleted" if current.nil? && array.size > 1
    content_tag(:div, options) do
      if unique_parts.size < 2 # i.e. part has no internal change
        render :partial => 'part', :locals => {:part => unique_parts.first}
      else
        render :partial => 'part_diff', :locals => {:previous => previous, :current => current}
      end
    end
  end
  
  def layout_diff(version)
    layout_ids = version.diff[:layout_id] || [version.instance.layout_id]
    return "" if layout_ids.compact.empty?
    field_diff layout_ids.map {|layout_id| layout_id.nil? ? "" : Layout.find(layout_id).name }
  end

  def status_diff(version)
    status_ids = version.diff[:status_id] || [version.instance.status_id]
    return "" if status_ids.compact.empty?
    field_diff status_ids.map {|status_id| status_id.nil? ? "" : Status.find(status_id).name }
  end
end
