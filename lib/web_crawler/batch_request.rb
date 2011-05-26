module WebCrawler

  class BatchRequest

    attr_reader :urls, :responses, :requests
    attr_writer :requests
    
    include Enumerable

    def initialize(*urls)
      @options = urls.last.is_a?(Hash) ? urls.pop : { }
      set_handler

      @urls, @requests = urls.flatten, []
      init_requests!
    end

    def process
      if @handler
        @handler.process
      else
        @responses ||= requests.map &:process
      end
    end

    def each &block
      @responses = []
      requests.each do |req|
        @responses << req.process
        block.call(@responses.last)
      end
    end

    def responses=(value)
      @responses += value.flatten
    end

    def response
      responses.first
    end

    def build_request(url)
      request_class.new(url)
    end

    protected

    def set_handler
      @handler = WebCrawler::HandlerParser.new(@options[:parser], self) if @options[:parser]
    end

    def init_requests!
      @requests = @urls.map { |url| build_request(url) }
    end

    def request_class
      @options[:cached] ? CachedRequest : Request
    end
  end

end