module WebCrawler

  class BatchRequest

    attr_reader :urls, :responses, :requests

    include Enumerable

    def initialize(*urls)
      options = urls.last.is_a?(Hash) ? urls.pop : { }
      set_handler(options[:handler]) if options[:handler]
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

    def response
      responses.first
    end

    protected

    def set_handler(parser)
      @handler = WebCrawler::Handler.new(parser, self)
    end

    def init_requests!
      @requests = @urls.map do |url|
        Request.new(url)
      end
    end

  end

end