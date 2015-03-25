require 'typhoeus'
require 'nokogiri'
require 'uri'

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
      links = attributes_by_xpath('//a', 'href')
      resolve_relative_links links
    end

    def url
      @response.request.base_url
    end

    def javascripts
      links = attributes_by_xpath('//script[@type="text/javascript"]', 'src')
      resolve_relative_links links
    end

    def stylesheets
      links = attributes_by_xpath('//link[@rel="stylesheet"]', 'href')
      resolve_relative_links links
    end

    def images
      links = attributes_by_xpath('//img', 'src')
      resolve_relative_links links
    end

    private

    def document
      @document ||= Nokogiri::HTML html
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

    def resolve_relative_links(links)
      links.map {|l| resolve_relative_link l }
    end

    def attributes_by_xpath(xpath, attribute_name)
      document.xpath(xpath).map do |node|
        node[attribute_name]
      end
    end
  end
end
