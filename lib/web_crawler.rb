require "net/http"
require "net/https"
require 'uri'
require 'forwardable'

require "ext/hash"
require "ext/array"
require "ext/http_response"
require "active_support/core_ext"
require "web_crawler/version"

module WebCrawler
  autoload :Request, 'web_crawler/request'
  autoload :CachedRequest, 'web_crawler/cached_request'
  autoload :Response, 'web_crawler/response'
  autoload :BatchRequest, 'web_crawler/batch_request'
  autoload :Handler, 'web_crawler/handler'
  autoload :HandlerParser, 'web_crawler/handler'
  autoload :CacheAdapter, 'web_crawler/cache_adapter'
  autoload :Configurable, 'web_crawler/configuration'
  autoload :Configuration, 'web_crawler/configuration'

  autoload :FactoryUrl, 'web_crawler/factory_url'
  autoload :Follower, 'web_crawler/follower'
  autoload :Parsers, 'web_crawler/parsers'
  autoload :Utility, 'web_crawler/utility'

  autoload :View, 'web_crawler/view'
  autoload :CLI, 'web_crawler/cli'
  autoload :Application, 'web_crawler/application'
  autoload :Base, 'web_crawler/base'

  include Configurable
  extend Utility

  def self.logger
    config.logger
  end

end

