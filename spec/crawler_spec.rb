require 'spec_helper'
require 'nokogiri'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :typhoeus
  config.configure_rspec_metadata!
  config.default_cassette_options = {:record => :new_episodes}
end

describe Crawler do

  let(:url) { 'http://xkcd.com' }

  it 'accepts a URL' do
    VCR.use_cassette('site_map') do
      expect { Crawler.new url }.to_not raise_error
    end
  end

  describe 'site map generation' do

    it 'generates a JSON document' do
      VCR.use_cassette('site_map') do
        crawler = Crawler.new url
        site_map = crawler.site_map
        expect { JSON.parse site_map }.to_not raise_error
      end
    end

    it 'indexes a page only once' do
      VCR.use_cassette('site_map') do
        crawler = Crawler.new url
        site_map = JSON.parse crawler.site_map
        base_pages = site_map['pages'].select do |page|
          page['url'] == url
        end
        expect(base_pages.count).to eq 1
      end
    end
  end
end
