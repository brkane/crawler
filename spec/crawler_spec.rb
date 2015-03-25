require 'spec_helper'
require 'nokogiri'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :typhoeus
  config.configure_rspec_metadata!
end

describe Crawler do

  let(:url) { 'http://xkcd.com' }
  subject(:crawler) { Crawler.new url }

  it 'accepts a URL' do
    expect { crawler }.to_not raise_error
  end

  describe 'site map generation' do

    it 'generates an HTML document' do
      site_map = crawler.site_map
      expect { Nokogiri::HTML site_map }.to_not raise_error
    end
  end
end   
