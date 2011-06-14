require "spec_helper"

describe WebCrawler::Base do
  require "fixtures/my_crawler"

  before(:all) do
    @uri_map = FakeWeb::Registry.instance.uri_map
    FakeWeb.clean_registry

    MyCrawler.targets.each do |url|
      FakeWeb.register_uri(:get, url, :body => 'spec/fixtures/example.xml', :content_type => "text/html; charset=windows-1251")
    end
  end

  after(:all) do
    FakeWeb::Registry.instance.uri_map = @uri_map
  end

  describe ' > ', MyCrawler do
    subject { MyCrawler.new }

    it "should be instance of MyCrawler" do
      subject.should be_a MyCrawler
      subject.should be_a_kind_of described_class
    end

    it "should have a target urls" do
      subject.targets.should be_a ::Set
      subject.targets.should have(20).urls
    end

    it "should generate an urls" do
      pattern = "www.example.com/category_:category/page:page/"
      options = { :category => [1, 2, 3, 4], :page => 1..3 }
      described_class.send(:generate_urls, pattern, options).should == ["www.example.com/category_1/page1/",
                                                                        "www.example.com/category_1/page2/",
                                                                        "www.example.com/category_1/page3/",
                                                                        "www.example.com/category_2/page1/",
                                                                        "www.example.com/category_2/page2/",
                                                                        "www.example.com/category_2/page3/",
                                                                        "www.example.com/category_3/page1/",
                                                                        "www.example.com/category_3/page2/",
                                                                        "www.example.com/category_3/page3/",
                                                                        "www.example.com/category_4/page1/",
                                                                        "www.example.com/category_4/page2/",
                                                                        "www.example.com/category_4/page3/"]
    end

    it "logger should be attached to tmp/file.log" do
      subject.logger.should be_a Logger
      subject.logger.instance_variable_get(:@logdev).dev.path.should == '/tmp/file.log'
    end

    it "logger should be attached to Logger.new(STDERR)" do
      class MyCrawler
        log_to Logger.new(STDERR)
      end
      subject.logger.should be_a Logger
      subject.logger.instance_variable_get(:@logdev).dev.should == STDERR
    end

    it "cache should be set" do
      WebCrawler.config.cache.adapter.should be_a WebCrawler::CacheAdapter::Base
    end

    it "follow should collect urls from given url and fill targets" do
      FakeWeb.register_uri(:get, urls_board_path, :body => follower_body)
      FakeWeb.register_uri(:get, 'http://example.com/2323.html', :body => '')
      FakeWeb.register_uri(:get, 'http://example.com/2323.html?rr=1', :body => '')
      class TestCrawler < WebCrawler::Base
        target 'http://example.com/follower' do |targets|
          follow targets, :only => /\/\d+\.html/
        end
      end
      TestCrawler.run
      TestCrawler.targets.should == Set["http://example.com/2323.html", "http://example.com/2323.html?rr=1"]
    end

    context 'parsing' do

      context 'context' do

        it 'should initialize mappers' do
          subject.mappers.should be_a Array
          subject.mappers.should have(1).parser
          subject.mappers.first.should be_a WebCrawler::Parsers::Mapper
        end

        context 'mapping' do
          subject { MyCrawler.new.mappers.first.mapping }

          let(:mapping_keys) { ["link",
                                "name",
                                "region",
                                "salary",
                                "description",
                                "contacts",
                                "company",
                                "published",
                                "expire",
                                "catalog item"] }

          it { should be_a Hash }
          it { should_not be_empty }
          it { subject.keys.should == mapping_keys }
        end

        context 'run' do
          it 'parse all elements and return Array' do
            result = subject.run
            result.should be_a Hash
            result.keys.first.should == :jobs
            result.values.flatten.should have(100).items
          end

          it 'parse all elements and return JSON string' do
            result = subject.run :json
            json   = JSON.parse(result)

            result.should be_a String
            result.should =~ /\[{"source_link":/
            json.should be_a Hash
            json.values.flatten.should have(100).items
          end

          it 'parse all elements and return JSON string' do
            result = subject.run :yaml
            yaml   = YAML.load(result)

            result.should be_a String
            result.should =~ /^---/
            yaml.should be_a Hash
            yaml.values.flatten.should have(100).items
          end
        end

      end

    end

  end

end