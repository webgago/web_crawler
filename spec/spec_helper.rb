$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "/../lib")))

require 'rspec'
require "web_crawler"
require "fake_web"

#Rspec.configure do |c|
#  c.mock_with :rspec
#end