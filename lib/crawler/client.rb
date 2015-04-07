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
      visit_page Page.new(@base_url)
      @visited_pages.keys.map do |key|
        @visited_pages[key]
      end  
    end

    def visit_page(page)
      return if @visited_pages[page.url]

      @visited_pages[page.url] = page
      page.linked_pages.each do |page|
        visit_page page
      end
    end
  end
end
