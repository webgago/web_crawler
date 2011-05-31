module WebCrawler

  class CachedRequest < Request
    extend ::Forwardable

    def initialize(url, options = { })
      super(url)
      @cache = options[:cache] || WebCrawler.config.cache_adapter
    end

    def process
      cached do
        Response.new *fetch(url)
      end
    end

    protected

    def cached
      @response = if @cache.exist? url
                    @cache.get url
                  else
                    @cache.put yield
                  end
      @response
    end

  end

end
