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
      local_links = links.select do |link|
        link_uri = URI.parse link
        uri.host == link_uri.host
      end
      local_links.map do |link|
        Page.new link
      end
    end

    def links
      document.xpath('//a').map do |link_node|
        link_node.get 'href'
      end
    end

    def url
      @response.request.base_url
    end

    private

    def document
      @document ||= Oga.parse_html html
    end

    def uri
      URI.parse url
    end
  end
end
