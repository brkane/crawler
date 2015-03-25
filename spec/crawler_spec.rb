require 'spec_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :typhoeus
  config.configure_rspec_metadata!
end

describe Crawler do

  let(:url) { 'http://xkcd.com' }

  it 'accepts a URL' do
    expect { Crawler.new url }.to_not raise_error
  end
end   
