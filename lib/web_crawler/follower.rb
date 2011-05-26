class WebCrawler::Follower

  def initialize(*responses)
    @options   = responses.last.is_a?(Hash) ? responses.pop : {}
    @responses = responses.flatten
  end

  def process
    WebCrawler::BatchRequest.new(collect).process
  end

  def follow(response)
    @responses << response
    self
  end

  def collect
    @responses.map do |response|
      parser = WebCrawler::Parsers::Url.new(response.url.host, url: response.url.request_uri, same_host: @options[:same_host])
      parser.parse(response.body) do |url|
        url
      end
    end
  end

end