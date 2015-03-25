require 'json'

module Crawler

  class Client

    def initialize(url)
      @base_url = url
    end

    def site_map
      JSON.pretty_generate( { 'pages' => pages } )
    end

    def pages
      @visited_pages ||= {}
      visit_page @base_url
      @visited_pages.keys.map do |key|
        @visited_pages[key]
      end  
    end

    def visit_page(url)
      return if @visited_pages[url]

      page = Page.new url
      @visited_pages[url] = page
      page.local_links.each do |link|
        visit_page link
      end
    end
  end
end
