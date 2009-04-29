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
    options = {:class => "page"}
    options[:class] += " added" if previous.nil?
    options[:class] += " deleted" if current.nil? && array.size > 1
    content_tag(:div, options) do
      if array.compact.size < 2 # i.e. part has no internal change
        render :partial => 'part', :locals => {:part => previous}
      else
        render :partial => 'part_diff', :locals => {:previous => previous, :current => current}
      end
    end
  end
end
