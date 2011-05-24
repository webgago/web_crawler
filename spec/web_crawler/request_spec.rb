require "spec_helper"

describe WebCrawler::Request do

  let(:success_url) { 'example.com/success' }
  let(:failure_url) { 'example.com/failure' }

  before(:each) do
    @body = "Example body"
    FakeWeb.register_uri(:get, "http://example.com/success", :body => @body, :status => ["200", "OK"])
    FakeWeb.register_uri(:get, "http://example.com/failure", :body => @body, :status => ["503", "Internal error"])
  end

  subject { WebCrawler::Request.new(success_url) }

  it "should fetch the url" do
    subject.process.should be_a WebCrawler::Response
    subject.process.body.should be @body
  end

  it "should be success" do
    subject.process.should be_success
  end

  it "should be failure" do
    WebCrawler::Request.new(failure_url).process.should be_failure
  end

end
