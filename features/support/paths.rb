def path_to(page_name)
  case page_name
  
  when /the homepage/i
    root_path
  
  when /edit the page/i
    edit_admin_page_path(@page)
  # Add more page name => path mappings here
  
  else
    raise "Can't find mapping from \"#{page_name}\" to a path."
  end
end