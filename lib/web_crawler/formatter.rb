module WebCrawler::Formatter

  autoload :CSV, 'web_crawler/formatter/csv'
  autoload :JSON, 'web_crawler/formatter/json'
  autoload :XML, 'web_crawler/formatter/xml'

  class Base
    attr_reader :input

    def initialize(input, options = { })
      @options = options
      @input   = input
    end

    def process
      input.map { |i| format(i) }.join
    end

    def format(item)
      raise NotImplementedError
    end
  end

end