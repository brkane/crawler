# Site Crawler
Site crawler and site map generator

Given a website URL it follows all page links in the same subdomain. 
Outputs a JSON document containing each page crawled, listing all
contained links, javascript, stylesheet and image assets.

Usage
-----

    $:.unshift './lib'
    require 'crawler'
    c = Crawler.new 'http://xkcd.com'
    s.site_map
