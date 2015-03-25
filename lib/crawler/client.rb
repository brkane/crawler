
module Crawler

  class Client

    def initialize(url)
      @page = Page.new url
    end

    def site_map
      doc = StringIO.new
      doc << '<html>'
      pages.each do |page|
        doc << "<div id=\"#{page.url}\" title=\"#{page.title}\"></div>"
      end
      doc << '</html>'
      doc.string
    end

    def pages
      @page.linked_pages
    end
  end
end
