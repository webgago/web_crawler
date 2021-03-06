module WebCrawler

  class Request

    HEADERS = {
        'User-Agent'      => 'Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1',
        'Accept'          => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'en-us,en;q=0.5',
        'Accept-Charset'  => 'utf-8;windows-1251;q=0.7,*;q=0.7',
        'Cache-Control'   => 'max-age=0'
    }

    attr_reader :url, :response

    def initialize(url, custom_headers = { })
      @url, @request = normalize_url(url), { }
      @headers = HEADERS.dup.merge(custom_headers)
      @ready   = false
    end

    def ready?
      @ready
    end

    def process
      @response = Response.new *fetch(url)
      @ready    = true
      response
    rescue Errno::ECONNREFUSED => e
      WebCrawler.logger.error "request to #{url} failed: #{e.message}"
      return nil
    end

    def inspect
      "#<#{self.class}:#{self.object_id} @url=\"#{@url.to_s}\">"
    end

    protected

    def request_for(host, port=nil)
      @request[[host, port]] = Net::HTTP.new(host, port) #.tap { |http| http.set_debug_output(STDERR) }
    end

    def normalize_url(url)
      URI.parse(url.index("http") == 0 ? url : "http://" + url)
    rescue URI::Error
      WebCrawler.logger.debug "#{url} bad URI(is not URI?)"
    end

    def fetch(uri, limit = 3, redirect_path = nil)
      raise ArgumentError, "HTTP redirect too deep. #{redirected_from} => #{uri}" if limit <= 0

      response = request_for(uri.host, uri.port).get(uri.request_uri, headers)

      case response
        when Net::HTTPRedirection then
          @headers['Cookie'] = response['Set-Cookie'] if response['Set-Cookie']
          fetch(normalize_url(response['location']), limit - 1, [redirect_path, uri])
        else
          response.redirect_path = redirect_path if redirect_path
          [uri, response]
      end
    end

    def headers
      @headers
    end

  end

end
