
module Crawler

  class Client

    def initialize(url)
    end

    def site_map
      Nokogiri::HTML::Builder.new(encoding: 'utf-8').to_html
    end
  end
end
