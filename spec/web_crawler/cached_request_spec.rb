require "spec_helper"

FakeWeb.register_uri(:get, "http://example.com/1", :body => "Example body1")
FakeWeb.register_uri(:get, "http://example.com/2", :body => "Example body2")
FakeWeb.register_uri(:get, "http://example.com/", :body => "Example body")

FakeWeb.allow_net_connect = false

describe 'Cached requests' do

  let(:urls) { ['example.com/1', 'example.com/2', 'example.com'] }

  it 'should not send requests to the web if cache exists' do
    FakeWeb.register_uri(:get, "http://example.com/cached", :body => "cached Example body1")
    first_response = FakeWeb.response_for :get, "http://example.com/cached"

    WebCrawler::BatchRequest.new("http://example.com/cached").process
    WebCrawler::config.cache.adapter.put(WebCrawler::Response.new(URI.parse("http://example.com/cached"), first_response))

    cached_response = WebCrawler::config.cache.adapter.get("http://example.com/cached")
    FakeWeb.should_not_receive(:response_for)

    WebCrawler::BatchRequest.new("http://example.com/cached").process.first.should be cached_response
  end

  it 'should not be cached' do
    FakeWeb.register_uri(:get, "http://example.com/cached", :body => "cached Example body1")
    first_response = FakeWeb.response_for :get, "http://example.com/cached"

    WebCrawler::BatchRequest.new("http://example.com/cached").process
    WebCrawler::config.cache.adapter.put(WebCrawler::Response.new(URI.parse("http://example.com/cached"), first_response))

    cached_response = WebCrawler::config.cache.adapter.get("http://example.com/cached")

    WebCrawler::BatchRequest.new("http://example.com/cached", no_cached: true).process.first.should_not be cached_response
  end
end