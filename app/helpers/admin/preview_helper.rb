module Admin::PreviewHelper
  def live_page_url(page)
    site_preview_url(:live, page)
  end

  def dev_page_url(page)
    site_preview_url(:dev, page)
  end
  
  def site_preview_url(mode, page)
    page = mode == :dev ? page.current_dev : page.current_live
    protocol = (@controller || self).request.protocol
    host = (@controller || self).request.host_with_port
    host = case mode
    when :dev
      Radiant::Config['dev.host'] || ("dev." + host)
    when :live
      Radiant::Config['live.host'] || host
    end
    protocol + host + page.url
  end
end