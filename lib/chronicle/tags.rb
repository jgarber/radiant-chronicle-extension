module Chronicle::Tags
  include Radiant::Taggable

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
end
