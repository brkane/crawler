require 'typhoeus'
require 'oga'

module Crawler

  class Page

    def initialize(url)
      @response = Typhoeus.get url
      @response = Typhoeus.get @response.headers["Location"] if @response.code == 301
    end

    def html
      @response.body
    end

    def linked_pages
      links.map do |link|
        Page.new link
      end
    end

    def links
      document.xpath('//a').map do |link_node|
        link_node.get 'href'
      end
    end

    private

    def document
      @document ||= Oga.parse_html html
    end
  end
end
