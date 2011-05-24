require "net/http"
require "net/https"
require 'uri'

module WebCrawler
  autoload :Request, 'web_crawler/request'
  autoload :Response, 'web_crawler/response'
  autoload :BatchRequest, 'web_crawler/batch_request'
  autoload :Handler, 'web_crawler/handler'
end
