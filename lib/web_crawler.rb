require "net/http"
require "net/https"
require 'uri'
require 'forwardable'

require "ext/hash"

module WebCrawler
  autoload :Request, 'web_crawler/request'
  autoload :CachedRequest, 'web_crawler/cached_request'
  autoload :Response, 'web_crawler/response'
  autoload :BatchRequest, 'web_crawler/batch_request'
  autoload :Handler, 'web_crawler/handler'
  autoload :CacheAdapter, 'web_crawler/cache_adapter'
  autoload :Configurable, 'web_crawler/configuration'
  autoload :Configuration, 'web_crawler/configuration'


  autoload :FactoryUrl, 'web_crawler/factory_url'

  include Configurable
 
end
