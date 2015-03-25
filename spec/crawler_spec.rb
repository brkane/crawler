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

    it 'generates an HTML document' do
      VCR.use_cassette('site_map') do
        crawler = Crawler.new url
        site_map = crawler.site_map
        expect { Nokogiri::HTML site_map }.to_not raise_error
      end
    end

    it 'contains one <div> per page', :vcr do
      VCR.use_cassette('site_map') do
        crawler = Crawler.new url
        site_map = Nokogiri::HTML crawler.site_map
        expect(site_map.xpath('//div').count).to eq 14
      end
    end
  end
end
