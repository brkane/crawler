require 'typhoeus'
require 'nokogiri'
require 'uri'

module Crawler

  class Page

    attr_reader :url

    def initialize(url)
      uri = URI.parse url
      @url = "#{uri.scheme}://#{uri.host}#{uri.path}"

      redirects = 0
      @response = Typhoeus.get @url
      while @response.code == 301 && redirects <= 3
        @response = Typhoeus.get @response.headers['Location']
        redirects += 1
      end
      @url = @response.request.url
    end

    def html
      @response.body || ""
    end

    def linked_pages
      local_links.map do |link|
        Page.new link
      end
    end

    def links
      links = attributes_by_xpath('//a', 'href')
      resolve_relative_links links
    end

    def local_links
      links.select do |link|
        link_uri = URI.parse link
        uri.host == link_uri.host
      end
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

    def title
      title = ""
      title_node = document.at_css('title')
      title = title_node.content if title_node
      title
    end

    def to_json(options = {})
      hash = { 
        'title' => title,
        'url'   => url,
        'links' => links,
        'javascripts' => javascripts,
        'stylesheets' => stylesheets,
        'images'      => images
      }
      JSON.pretty_generate(hash, options)
    end

    private

    def document
      @document ||= Nokogiri::HTML html
    end

    def uri
      URI.parse url
    end

    def resolve_relative_link(link)
      begin
        escaped_link = URI.escape link
        link_uri = URI.parse escaped_link
        link_uri.scheme = uri.scheme unless link_uri.scheme
        link_uri.host = uri.host unless link_uri.host || link_uri.scheme == 'mailto'
        link_uri.to_s
      rescue URI::InvalidURIError => e
        ""
      end
    end

    def resolve_relative_links(links)
      resolved_links = links.map {|l| resolve_relative_link l }
      resolved_links.reject {|l| l.empty? }
    end

    def attributes_by_xpath(xpath, attribute_name)
      document.xpath(xpath).map do |node|
        node[attribute_name] || ""
      end
    end
  end
end
