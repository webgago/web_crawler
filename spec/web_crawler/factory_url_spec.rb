require "spec_helper"

describe WebCrawler::FactoryUrl do

  it "should generate urls with block" do
    first_param = [1,2,3]
    second_param = 10...15

    factory = WebCrawler::FactoryUrl.new(first_param, second_param) do |*args|
      random = rand(3000)
      "www.example.com/%s/%s.html?rid=#{random}" % args
    end
    urls = factory.factory

    urls.should be_a Array
    factory.params.size.should == 15
    urls.should have(factory.params.size).urls
    urls.first.should =~ /www\.example\.com\/1\/10\.html/
  end

  it "should generate urls with pattern" do
    first_param = [1,2,3]
    second_param = 10...15

    factory = WebCrawler::FactoryUrl.new("www.example.com/$1/$2.html", first_param, second_param)
    urls = factory.factory

    urls.should be_a Array
    factory.params.size.should == 15
    urls.should have(factory.params.size).urls
    urls.first.should == "www.example.com/1/10.html"
  end
  
end