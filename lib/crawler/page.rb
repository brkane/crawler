require 'typhoeus'

module Crawler

  class Page

    def initialize(url)
      @response = Typhoeus.get url
    end

    def html
      @response.body
    end
  end
end
