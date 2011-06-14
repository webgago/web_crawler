require "parallel"

module WebCrawler

  # Usage:
  #  BatchRequest.new(urls).process #=> array of Responses
  #
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
        block_given? ? yield(@handler.process) : @handler.process
      else
        ready = requests.select{|r| r.ready? }
        @responses ||= Parallel.map(requests - ready) do |req|
          WebCrawler.logger.info "start request to #{req.url.to_s}"
          block_given? ? yield(req.process) : req.process
        end.compact + ready.map(&:process)
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
      !@options[:no_cached] && WebCrawler.config.cache.adapter.is_a?(WebCrawler::CacheAdapter::Base) ? CachedRequest : Request
    end
  end

end