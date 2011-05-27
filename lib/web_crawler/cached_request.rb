module WebCrawler

  class CachedRequest < Request
    extend ::Forwardable

    attr_accessor :adapter
    protected :adapter, :adapter=

    def initialize(url, options = { })
      super(url)
      self.adapter = options[:adapter] || WebCrawler.config.cache_adapter
    end

    def process
      cached do
        Response.new *fetch(url)
      end
    end

    protected

    def cached
      @response = if @adapter.exist? url
                    @adapter.get url
                  else
                    @adapter.put yield
                  end

      @response
    end

  end

end
