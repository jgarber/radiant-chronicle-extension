module Admin::VersionsHelper
  include HTMLDiff

  def format_diff(*array)
    array = array.first if array.first.is_a?(Array)
    return "" if array.compact.empty?
    if array.length > 1
      content_tag(:span, array[0], :class => "from") +
      " &rarr; " +
      content_tag(:span, array[1], :class => "to")
    else
      array.first
    end
  end

  def field_diff(version, field, empty_value='')
    array = version.diff[field] || [version.instance.send(field)]
    array.collect! {|a| (a.nil? || a.empty?) ? h(empty_value) : a }
    format_diff(array)
  end

  def part_diff(array)
    previous, current = *array
    unique_parts = array.compact
    options = {:class => "page"}
    options[:class] += " added" if previous.nil?
    options[:class] += " deleted" if current.nil? && array.size > 1
    contents = if unique_parts.size < 2 # i.e. part has no internal change
      render :partial => 'admin/versions/part_nodiff.html.haml', :locals => {:part => unique_parts.first}
    else
      render :partial => 'admin/versions/part_diff.html.haml', :locals => {:previous => previous, :current => current}
    end
    content_tag(:div, contents, options)
  end

  def layout_diff(version)
    nil_value = h("<inherit>")
    layout_ids = version.diff[:layout_id] || [version.instance.layout_id]
    return nil_value if layout_ids.compact.empty?
    format_diff layout_ids.map {|layout_id| layout_id.nil? ? nil_value : Layout.find(layout_id).name }
  end

  def status_diff(version)
    status_ids = version.diff[:status_id] || [version.instance.status_id]
    return "" if status_ids.compact.empty?
    format_diff status_ids.map {|status_id| status_id.nil? ? "" : Status.find(status_id).name }
  end
end
