require "spec_helper"

FakeWeb.register_uri(:get, "http://example.com/1", :body => "Example body1")
FakeWeb.register_uri(:get, "http://example.com/2", :body => "Example body2")
FakeWeb.register_uri(:get, "http://example.com/", :body => "Example body")

describe WebCrawler::BatchRequest do

  let(:urls) { ['example.com', 'example.com/1', 'example.com/2'] }
  let(:http_response) { Net::HTTPResponse.new('', '', '') }
  let(:responses) { urls.map { |url| WebCrawler::Response.new(url, http_response) } }

  def response(url)
    WebCrawler::Response.new(url, http_response)
  end

  def request(url)
    WebCrawler::Request.new(url).stub(:process).and_return(response(url))
  end

  subject { described_class.new(urls) }

  it "should initialize batch of requests for given urls" do
    subject.requests.should be_a Array
    subject.requests.should have(3).members
    subject.requests.all? { |r| r.is_a? WebCrawler::Request }.should be_true
  end

  it "should process requests" do
    subject.process.should be_a Array
    subject.process.first.should be_a WebCrawler::Response
  end

end