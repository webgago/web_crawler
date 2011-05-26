$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "/../lib")))

require 'rspec'
require "web_crawler"
require "fake_web"

require 'fake_web_generator'

RSpec.configure do |c|
  c.mock_with :rspec
  c.include FakeWebGenerator
end

WebCrawler.configure do
  config.cache_adapter = WebCrawler::CacheAdapter::Memory.new
end

