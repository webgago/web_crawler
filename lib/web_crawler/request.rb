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

    def initialize(url)
      @url, @request = normalize_url(url), {}
      @headers = HEADERS.dup
    end

    def process
      @response = Response.new *fetch(url)
    end

    def inspect
      "#<#{self.class}:#{self.object_id} @url=\"#{@url.to_s}\">"
    end

    protected

    def request_for(host, port=nil)
      @request[[host, port]] =  Net::HTTP.new(host, port)#.tap { |http| http.set_debug_output(STDERR) }
    end

    def normalize_url(url)
     URI.parse(url.index("http") == 0 ? url : "http://" + url)
    end

    def fetch(uri, limit = 3, redirected_from = nil)
      raise ArgumentError, "HTTP redirect too deep. #{redirected_from} => #{uri}" if limit <= 0
      response = request_for(uri.host, uri.port).get(uri.request_uri, headers)
      case response
        when Net::HTTPRedirection then
          @headers['Cookie'] = response['Set-Cookie'] if response['Set-Cookie']
          fetch(normalize_url(response['location']), limit - 1, [*[*redirected_from], uri])
        else
          [uri, response.extend(ResponseExtension).set_redirected(redirected_from && redirected_from.map(&:to_s))]
      end
    end

    def headers
      @headers
    end

    module ResponseExtension

      def set_redirected(value)
        @redirected = [*value].size > 1 ? value : [*value].first
        self
      end

      def redirected
        @redirected
      end

      def redirected?
        !!redirected
      end
      
    end

  end

end
