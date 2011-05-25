module WebCrawler::CacheAdapter

  class Memory < Base
    class << self
      attr_accessor :cache
    end

    self.cache = {}
    
    def put response
      response.tap { self.class.cache[response.url.to_s] = response }
    end
    
    def get uri
      self.class.cache[uri.to_s]
    end

    def exist? uri
      self.class.cache.key? uri.to_s
    end
  end

end