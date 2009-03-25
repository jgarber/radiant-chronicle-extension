module ChronicleSpecHelpers
  VALID_PAGE_PARAMS = {
    :title => 'New Page',
    :slug => 'page',
    :breadcrumb => 'New Page',
    :status_id => '1',
    :parent_id => nil
  }
  
  def destroy_test_page(title = @page_title)
    while page = get_test_page(title) do
      page.destroy
    end
  end
  
  def get_test_page(title = @page_title)
    Page.find_by_title(title)
  end
  
  def create_test_page(options = {})
    options[:title] ||= @page_title
    klass = options.delete(:class_name) || Page
    klass = Kernel.eval(klass) if klass.kind_of? String
    page = klass.new page_params(options)
    if page.save
      page
    else
      raise "page <#{page.inspect}> could not be saved"
    end
  end
  
  def page_save(page)
    page.save!
    page.parts.each { |part| part.save! }
  end
  
end