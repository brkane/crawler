
module Crawler

  class Client

    def initialize(url)
      @page = Page.new url
    end

    def site_map
      pages.to_json
    end

    def pages
      @page.linked_pages
    end
  end
end
