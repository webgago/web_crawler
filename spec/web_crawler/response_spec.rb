require "spec_helper"

FakeWeb.register_uri(:get, "http://example.com/", :body => "Example body")


describe WebCrawler::Response do

  let(:url) { 'example.com' }
  subject { WebCrawler::Request.new(url).process }

  it "should initialize with url and response" do
    described_class.new url, Net::HTTPResponse.new('', '', '')
  end

  it "should respond to HTTPResponse methods" do
    [:body, :http_version, :code, :message, :msg, :code_type].each do |meth|
      subject.should respond_to meth
    end
  end

  it "#to_s should be String and equal to #body and not equal to #inspect" do
    subject.to_s.should be_a String
    subject.to_s.should be subject.body
    subject.to_s.should_not be subject.inspect
  end

end