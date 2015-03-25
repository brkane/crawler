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
    subject(:page)  { Crawler::Page.new base_url }

    it 'generates pages for links in the page' do
      base_html = '<html><a href="http://google.com/pricing/">Pricing</a></html>'
      link_url  = 'http://google.com/pricing/'
      link_html = '<html>Pricing Page</html>'

      base_response = Typhoeus::Response.new( code: 200, body: base_html )
      Typhoeus.stub(base_url).and_return(base_response)
      link_response = Typhoeus::Response.new( code: 200, body: link_html )
      Typhoeus.stub(link_url).and_return(link_response)

      linked_page = page.linked_pages.first
      expect(linked_page.html).to eq link_html
    end

    it 'does not generate pages for links in different domains' do
      base_html = '<html><a href="http://amazon.com/pricing/">Pricing</a></html>'
      link_url  = 'http://amazon.com/pricing/'
      link_html = '<html>Pricing Page</html>'

      base_response = Typhoeus::Response.new( code: 200, body: base_html )
      Typhoeus.stub(base_url).and_return(base_response)
      link_response = Typhoeus::Response.new( code: 200, body: link_html )
      Typhoeus.stub(link_url).and_return(link_response)

      remote_domain_pages = page.linked_pages.reject do |linked_page|
        page_uri = URI.parse(page.url)
        linked_uri = URI.parse(linked_page.url)
        page_uri.host == linked_uri.host
      end

      expect(remote_domain_pages).to be_empty
    end

    it 'does not generate pages for links in different subdomains' do
      base_html = '<html><a href="http://links.google.com/pricing/">Pricing</a></html>'
      link_url  = 'http://links.google.com/pricing/'
      link_html = '<html>Pricing Page</html>'

      base_response = Typhoeus::Response.new( code: 200, body: base_html )
      Typhoeus.stub(base_url).and_return(base_response)
      link_response = Typhoeus::Response.new( code: 200, body: link_html )
      Typhoeus.stub(link_url).and_return(link_response)

      remote_domain_pages = page.linked_pages.reject do |linked_page|
        page_uri = URI.parse(page.url)
        linked_uri = URI.parse(linked_page.url)
        page_uri.host == linked_uri.host
      end

      expect(remote_domain_pages).to be_empty
    end

    it 'uses the current page uri scheme + host if link is relative' do
      base_html = '<html><a href="/pricing/">Pricing</a></html>'
      link_url  = 'http://google.com/pricing/'
      link_html = '<html>Pricing Page</html>'

      base_response = Typhoeus::Response.new( code: 200, body: base_html )
      Typhoeus.stub(base_url).and_return(base_response)
      link_response = Typhoeus::Response.new( code: 200, body: link_html )
      Typhoeus.stub(link_url).and_return(link_response)

      linked_page = page.linked_pages.first
      expect(linked_page.html).to eq link_html
    end
  end

  describe 'static assets' do

    let(:url) { 'http://google.com/pricing/' }
    let(:html) { '''
      <html>
        <head>
          <script type="text/javascript" src="https://ssl.google-analytics.com/ga.js"></script>
          <link rel="stylesheet" media="screen" href="/assets/application-0123456789.css">
        </head>
        <body>
          <img src="/assets/awesome-image.png" alt="Awesome Image">
        </body>
      </html>
    ''' }
    subject(:page) { Crawler::Page.new url }

    it 'can list javascript references' do
      response = Typhoeus::Response.new( code: 200, body: html )
      Typhoeus.stub(url).and_return(response)

      expect(page.javascripts).to include("https://ssl.google-analytics.com/ga.js")
    end

    it 'can list CSS references' do
      response = Typhoeus::Response.new( code: 200, body: html )
      Typhoeus.stub(url).and_return(response)

      expect(page.stylesheets).to include("http://google.com/assets/application-0123456789.css")
    end
  end
end
