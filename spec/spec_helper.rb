$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "/../lib")))

require 'rspec'
require "web_crawler"
require "fake_web"

require 'fake_web_generator'

RSpec.configure do |c|
  c.mock_with :rspec
  c.include FakeWebGenerator

  c.before(:each) do
    WebCrawler.configure do
      config.logger        = nil
      config.cache_adapter = WebCrawler::CacheAdapter::Memory.new
      config.logger.level = Logger::ERROR
    end
  end
end


