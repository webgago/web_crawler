module WebCrawler::View

  autoload :Csv, 'web_crawler/view/csv'
  autoload :Json, 'web_crawler/view/json'
  autoload :Xml, 'web_crawler/view/xml'
  autoload :Plain, 'web_crawler/view/plain'
  autoload :Table, 'web_crawler/view/table'
  autoload :Runner, 'web_crawler/view/runner'

  extend self

  def factory(type, *args, &block)
    const_get(WebCrawler::Utility.camelize(type).to_sym).new(*args, &block)
  end

  class Base
    attr_reader :input

    class << self
      attr_accessor :default_options
      def default_options
        @default_options ||= { }
      end
    end

    def initialize(input, options = { })
      @options = self.class.default_options.merge (options || { })
      @input   = input
    end

    def render
      [*input].map { |i| format(i) }.join
    end

    def draw(output=$stdout)
      output.puts render
    end

    def format(item)
      item
    end
  end

end