module WebCrawler

  class Handler

    def initialize(parser, *responses_or_request)
      @parser = load_parser(parser)
      if responses_or_request.first.is_a?(BatchRequest)
        @target = responses_or_request.first
      else
        @target = responses_or_request.flatten
      end
    end

    def process
      @result ||= @target.map do |response|
        @parser.parse(response)
      end
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
      require underscore(parser)
      retry
    end

    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end

end