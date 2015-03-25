require 'crawler/client'
require 'crawler/page'

module Crawler

  def self.new(url)
    Crawler::Client.new url
  end
end
