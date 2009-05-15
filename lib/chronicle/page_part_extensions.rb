module Chronicle::PagePartExtensions
  def attributes_for_diff
    {
      "name" => name,
      "content" => content.gsub("\r\n", "\n"),
      "filter_id" => filter_id || ""
    }
  end
end