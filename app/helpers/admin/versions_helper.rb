module Admin::VersionsHelper
  def field_diff(array)
    if array.length > 1
      content_tag(:span, array[0], :class => "from") +
      " &rarr; " +
      content_tag(:span, array[1], :class => "to")
    else
      array.first
    end
  end
end
