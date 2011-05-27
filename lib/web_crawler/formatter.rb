module WebCrawler::Formatter

  autoload :Csv, 'web_crawler/formatter/csv'
  autoload :Json, 'web_crawler/formatter/json'
  autoload :Xml, 'web_crawler/formatter/xml'

  extend self

  def factory(type, *args, &block)
    const_get(WebCrawler::Utility.camelize(type).to_sym).new(*args, &block)
  end

  class Base
    attr_reader :input

    def initialize(input, options = { })
      @options = options
      @input   = input
    end

    def draw
      input.map { |i| format(i) }.join
    end

    def format(item)
      raise NotImplementedError
    end
  end

end