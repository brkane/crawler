require 'spec_helper'
require 'typhoeus'

describe Crawler::Page do

  context 'given a base url' do

    let(:url)      { 'http://google.com/' }
    let(:html)     { '<html>Hi There!</html>' }
    subject(:page) { Crawler::Page.new url }

    it 'fetches the page from the server' do
      response = Typhoeus::Response.new( code: 200, body: html )
      Typhoeus.stub(url).and_return(response)

      expect(page.html).to eq html
    end
  end
end
