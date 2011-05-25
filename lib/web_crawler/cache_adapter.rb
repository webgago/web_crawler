module WebCrawler

  module CacheAdapter

    autoload :Base, 'web_crawler/cache_adapter/base'
    autoload :Memory, 'web_crawler/cache_adapter/memory'
    autoload :File, 'web_crawler/cache_adapter/file'

  end

end