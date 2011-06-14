require "spec_helper"


describe WebCrawler::Follower do

  it "should collect all uniques urls from responses" do
    responses = WebCrawler::BatchRequest.new(urls_board_path).process
    urls      = WebCrawler::Follower.new(responses).collect

    urls.should have(9).urls
    urls.should == known_urls
  end

  it "should collect all the unique url with same host like in responses" do
    responses = WebCrawler::BatchRequest.new(urls_board_path).process
    urls      = WebCrawler::Follower.new(responses, same_host: true).collect

    urls.should have(6).urls
    urls.should == known_urls.reject { |u| u =~ /otherhost/ }
  end

  it "should collect all the unique url like a given regexp" do
    responses = WebCrawler::BatchRequest.new(urls_board_path).process
    urls      = WebCrawler::Follower.new(responses, only: /\/\d+\.html/).collect
    urls.should have(2).urls
    urls.should == known_urls.select { |u| u =~ /\/\d+\.html/ }
  end

  it "should process requests for following urls" do
    responses = WebCrawler::BatchRequest.new(urls_board_path).process
    follower  = WebCrawler::Follower.new responses
    responses += follower.process
    
    responses.should have(10).responses
    responses.first.should be_a WebCrawler::Response
    responses.first.url.to_s.should == urls_board_path
    responses.last.url.to_s.should == known_urls.last
  end
end