class VersionsDataset < Dataset::Base
  uses :home_page
  
  def load
    create_versioned_page "Published"
    create_versioned_page "Draft", :status_id => Status[:draft].id
    create_versioned_page "Page with Draft" do
      create_version :status_id => Status[:draft].id
    end
    create_versioned_page "Reviewed", :status_id => Status[:reviewed].id
    create_versioned_page "Hidden", :status_id => Status[:hidden].id
    create_versioned_page "Published with many versions" do
      create_version
      create_version
    end
    create_versioned_page "Draft with many versions", :status_id => Status[:draft].id do
      create_version
      create_version
    end
  end
  
  helpers do
    def create_versioned_page(name, attributes={}, &block)
      create_page(name, attributes) do
        create_version
        block.call if block_given?
      end
    end
    def create_version(attributes={})
      page = Page.find(@current_page_id)
      page.update_attributes(attributes)
    end
  end
  
end