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
        link_uri = URI.parse resolve_relative_link(link)
        uri.host == link_uri.host
      end
      local_links.map do |link|
        Page.new resolve_relative_link(link)
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

    def javascripts
      document.xpath('//script[@type="text/javascript"]').map do |script_node|
        link = script_node.get 'src'
        resolve_relative_link link
      end
    end

    def stylesheets
      document.xpath('//link[@rel="stylesheet"]').map do |stylesheet_node|
        link = stylesheet_node.get 'href'
        resolve_relative_link link
      end
    end

    private

    def document
      @document ||= Oga.parse_html html
    end

    def uri
      URI.parse url
    end

    def resolve_relative_link(link)
      link_uri = URI.parse link
      link_uri.scheme = uri.scheme unless link_uri.scheme
      link_uri.host = uri.host unless link_uri.host
      link_uri.to_s
    end
  end
end
