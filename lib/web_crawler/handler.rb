module WebCrawler

  class Handler

    def initialize(*responses_or_request, &handler)
      @handler = handler
      if responses_or_request.first.is_a?(BatchRequest)
        @target = responses_or_request.first
      else
        @target = responses_or_request.flatten
      end
    end

    def process
      @result ||= @target.map do |response|
        @handler.call(response, @target)
      end
    end

  end

  class HandlerParser < Handler
    def initialize(parser, *responses_or_request)
      @parser = load_parser(parser)
      super(*responses_or_request, &lambda { |response,*| @parser.parse(response) })
    end

    protected

    def load_parser(parser)
      case parser
        when String
          Object.const_get parser
        else
          parser.respond_to?(:parse) ? parser : raise(LoadParserError, 'Parser must respond to :parse')
      end
    rescue NameError
      $:.unshift File.expand_path('./')
      require WebCrawler.underscore(parser)
      retry
    end


  end
end