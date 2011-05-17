require "net/http"
require "net/https"
require 'uri'

module WebCrawler

  class Request

    HEADERS = {
        "User-Agent" =>  "Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.2.13) Gecko/20101206 Ubuntu/10.04 (lucid) Firefox/4.01",
        "Accept" =>  "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language" =>  "ru,en-us;q=0.7,en;q=0.3",
        "Accept-Charset" =>  "utf-8;q=0.7,*;q=0.7"
    }

    attr_reader :urls

    def initialize(*urls)
      @urls = normalize_urls(urls)
    end

    def response
      @response ||= exec
    end

    protected

    def normalize_urls(urls)
      urls.map do |url|
        url.index("http") == 0 ? url : "http://" + url
      end
    end

    def exec
      @urls.map do |url|
        [url, fetch(url)]
      end
    end

    def fetch(url, limit = 3)
      raise ArgumentError, 'HTTP redirect too deep' if limit <= 0
      url = URI.parse(url)
      response = Net::HTTP.start(url.host, url.port) {|http| http.get('/index.html', headers) }
      case response
        when Net::HTTPSuccess then
          response
        when Net::HTTPRedirection then
          fetch(response['location'], limit - 1)
        else
          response.error!
      end
    end

    def headers
      HEADERS
    end

  end

end
