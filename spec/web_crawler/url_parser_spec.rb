require "spec_helper"

describe WebCrawler::Parsers::Url do

  let(:host) { 'example.com' }
  let(:http_host) { 'http://example.com' }
  let(:https_host) { 'https://example.com/' }
  let(:current_page) { '/news/1000.html' }

  it "should add scheme to url" do
    described_class.new(host).host.to_s.should == 'http://example.com'
    described_class.new(host, secure: true).host.to_s.should == 'https://example.com'
  end

  it "should parse scheme from url and set @scheme" do
    described_class.new(https_host).scheme.should == 'https'
    described_class.new(host, secure: true).scheme.should == 'https'
    described_class.new(http_host).scheme.should == 'http'
    described_class.new(host).scheme.should == 'http'
  end

  it "should return nil if host not equal to initial host" do
    described_class.new(host, same_host: true).normalize('example.ru/news?sid=1').should be_nil
    described_class.new(host, same_host: true).normalize('http://example.ru/news?sid=1').should be_nil
    described_class.new(host, same_host: true).normalize('https://example.ru/news?sid=1').should be_nil
  end

  it "should join request_uri to initial host" do
    described_class.new(https_host).normalize('/news').should == 'https://example.com/news'
    described_class.new(https_host).normalize('/news?sid=1').should == 'https://example.com/news?sid=1'
    described_class.new(https_host).normalize('/news?sid=1#anchor').should == 'https://example.com/news?sid=1#anchor'
  end

  it "should join query string to initial current page" do
    described_class.new(host, url: current_page).normalize('?sid=1').should == 'http://example.com/news/1000.html?sid=1'
  end

  it "should join fragment string to initial current page" do
    described_class.new(host, url: current_page).normalize('#anchor').should == 'http://example.com/news/1000.html#anchor'
  end
end