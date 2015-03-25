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

    it 'follows redirects transparently' do
      redirect_url = 'https://google.com/'
      redirect_response = Typhoeus::Response.new( 
        code: 301, headers: { "Location" => redirect_url }
      )
      response = Typhoeus::Response.new( code: 200, body: html )
      Typhoeus.stub(url).and_return(redirect_response)
      Typhoeus.stub(redirect_url).and_return(response)

      expect(page.html).to eq html
    end
  end

  describe 'links' do

    let(:base_url)  { 'http://google.com/' }
    let(:base_html) { '<html><a href="http://google.com/pricing/">Pricing</a></html>' }
    let(:link_url)  { 'http://google.com/pricing/' }
    let(:link_html) { '<html>Pricing Page</html>' }
    subject(:page)  { Crawler::Page.new base_url }

    it 'generates pages for links in the page' do
      base_response = Typhoeus::Response.new( code: 200, body: base_html )
      Typhoeus.stub(base_url).and_return(base_response)
      link_response = Typhoeus::Response.new( code: 200, body: link_html )
      Typhoeus.stub(link_url).and_return(link_response)

      linked_page = page.linked_pages.first
      expect(linked_page.html).to eq link_html
    end
  end
end
