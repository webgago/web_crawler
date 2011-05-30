module WebCrawler::View

  autoload :Csv, 'web_crawler/view/csv'
  autoload :Json, 'web_crawler/view/json'
  autoload :Xml, 'web_crawler/view/xml'
  autoload :Plain, 'web_crawler/view/plain'
  autoload :Table, 'web_crawler/view/table'

  extend self

  def factory(type, *args, &block)
    const_get(WebCrawler::Utility.camelize(type).to_sym).new(*args, &block)
  end

  class Base
    attr_reader :input

    def initialize(input, options = { })
      @options = options || { }
      @input   = input
    end

    def render
      input.map { |i| format(i) }.join
    end

    def draw(output=$stdout)
      output.puts render
    end

    def format(item)
      raise NotImplementedError
    end
  end

end