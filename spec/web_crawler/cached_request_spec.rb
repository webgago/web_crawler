require "spec_helper"

FakeWeb.register_uri(:get, "http://example.com/1", :body => "Example body1")
FakeWeb.register_uri(:get, "http://example.com/2", :body => "Example body2")
FakeWeb.register_uri(:get, "http://example.com/", :body => "Example body")

FakeWeb.allow_net_connect = false

describe 'Cached requests' do

  let(:urls) { ['example.com/1', 'example.com/2', 'example.com'] }

  it 'should not send requests to the web if cache exists' do
    FakeWeb.register_uri(:get, "http://example.com/1", :body => "Example body1")
    first_response = FakeWeb.response_for :get, "http://example.com/1"

    FakeWeb.should_receive(:response_for).with(:get, "http://example.com/1").and_return { first_response }

    lambda {
      WebCrawler::BatchRequest.new("http://example.com/1", cached: true).process
    }.should raise_error(ArgumentError, /response must be a Net::HTTPResponse/)

    FakeWeb.should_not_receive(:response_for)

    WebCrawler::config.cache_adapter.put(WebCrawler::Response.new(URI.parse("http://example.com/1"), first_response))

    cached_response = WebCrawler::config.cache_adapter.get("http://example.com/1")
    WebCrawler::BatchRequest.new("http://example.com/1", cached: true).process.first.should be cached_response
  end

end