class WebCrawler::Follower

  attr_reader :options

  def initialize(*responses)
    @options   = responses.extract_options!
    @responses = responses.flatten
  end

  def process(options = { })
    WebCrawler::BatchRequest.new(collect, options).process
  end

  def follow(response)
    @responses += Array.wrap(response)
    self
  end

  def collect(&block)
    urls = @responses.map do |response|
      parser = WebCrawler::Parsers::Url.new(response.url.host, url: response.url.request_uri, same_host: @options[:same_host])
      parser.parse(response.body, &block)
    end.flatten
    urls = urls.select { |url| url =~ @options[:only] } if @options[:only]
    urls
  end

end