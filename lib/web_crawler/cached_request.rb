module WebCrawler

  class CachedRequest < Request
    extend ::Forwardable

    def initialize(url, options = { })
      super(url)
      @cache = options[:cache] || WebCrawler.config.cache.adapter
      @ready = true if @cache.exist? url
    end

    def process
      @response || cached do
        Response.new *fetch(url)
      end
    end

    protected

    def load_response
      @response = @cache.get url
    end

    def put_response(response)
      @response = @cache.put(response)
    end

    def cached
      if @cache.exist? url
        load_response
      else
        put_response(yield)
      end
      @response
    end

  end

end
