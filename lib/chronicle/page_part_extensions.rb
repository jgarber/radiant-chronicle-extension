module Chronicle::PagePartExtensions
  def attributes_for_diff
    {
      "name" => name,
      "content" => content,
      "filter_id" => filter_id || ""
    }
  end
end