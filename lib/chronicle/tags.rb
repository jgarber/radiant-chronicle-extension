module Chronicle::Tags
  include Radiant::Taggable
  def self.included(base)
    base.class_eval do
      alias_method_chain :children_find_options, :draft_versioning
    end
  end

  desc %{
    Renders the snippet specified in the @name@ attribute within the context of a page.

    *Usage:*

    <pre><code><r:snippet name="snippet_name" /></code></pre>

    When used as a double tag, the part in between both tags may be used within the
    snippet itself, being substituted in place of @<r:yield/>@.

    *Usage:*

    <pre><code><r:snippet name="snippet_name">Lorem ipsum dolor...</r:snippet></code></pre>
  }
  tag 'snippet' do |tag|
    if name = tag.attr['name']
      snippet = if dev?(request)
        # fastest way to find dev snippet is to find live one and then adjust for changed name
        s = Snippet.find_by_name(name.strip)
        if s.nil? # fallback for not found: try to find by current name
          s = Snippet.find(:all).map {|s| s.current }.find {|s| s.name == name }
        else # revoke find if found but name changed in current
          s = nil if s.name != s.current.name
        end
        (s && s.versioned?) ? s.current : s
      else
        Snippet.find_by_name_and_status_id(name.strip, Status[:published].id)
      end
      if snippet
        tag.locals.yield = tag.expand if tag.double?
        tag.globals.page.render_snippet(snippet)
      else
        raise StandardTags::TagError.new('snippet not found')
      end
    else
      raise StandardTags::TagError.new("`snippet' tag must contain `name' attribute")
    end
  end
  
  desc %{
    Inside this tag all page related tags refer to the page found at the @url@ attribute.
    @url@s may be relative or absolute paths.

    *Usage:*

    <pre><code><r:find url="value_to_find">...</r:find></code></pre>
  }
  tag 'find' do |tag|
    url = tag.attr['url']
    raise TagError.new("`find' tag must contain `url' attribute") unless url

    found = Page.find_by_url(absolute_path_for(tag.locals.page.url, url), !dev?(tag.globals.page.request))
    if page_found?(found)
      tag.locals.page = found
      tag.expand
    end
  end

  desc %{
    Page attribute tags inside this tag refer to the parent of the current page.

    *Usage:*
    
    <pre><code><r:parent>...</r:parent></code></pre>
  }
  tag "parent" do |tag|
    parent = tag.locals.page.parent.current
    tag.locals.page = parent
    tag.expand if parent
  end
  
  def children_find_options_with_draft_versioning(tag)
    options = children_find_options_without_draft_versioning(tag)
    options.merge!(:current => true) if dev?(tag.globals.page.request)
    options
  end
end
