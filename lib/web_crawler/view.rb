module WebCrawler::View

  autoload :Csv, 'web_crawler/view/csv'
  autoload :Json, 'web_crawler/view/json'
  autoload :Xml, 'web_crawler/view/xml'
  autoload :Plain, 'web_crawler/view/plain'
  autoload :Table, 'web_crawler/view/table'
  autoload :Runner, 'web_crawler/view/runner'
  autoload :Yaml, 'web_crawler/view/yaml'

  extend self

  def factory(type, *args, &block)
    (self.name + "::" + type.to_s.classify).constantize.new(*args, &block)
  end

  class Base
    attr_reader :input

    delegate :logger, :to => WebCrawler.logger
    
    class << self
      attr_accessor :default_options

      def default_options
        @default_options ||= { 'output' => $stdout }
      end
    end

    def initialize(input, options = { })
      @options = self.class.default_options.merge (options || { })
      @input   = input
    end

    def render
      [*input].map { |i| format(i) }.join
    end

    def draw(output=nil)
      begin
        present_output(output).puts render
      ensure
        output.close if output.respond_to? :close
      end
    end

    def format(item)
      item
    end

    protected

    def present_output(override=nil)
      @present_output = if override && override.respond_to?(:puts)
                          override
                        elsif @options['output'].is_a?(String)
                          output_to_file(@options['output'])
                        elsif @options['output'].respond_to? :puts
                          @options['output']
                        end
    end

    def output_to_file(filename)
      path = Pathname.new(filename)

      unless path.dirname.exist?
        info("#{path.dirname} not exist, try to create...")
        path.dirname.mkpath
      end
      
      path.open('w+')
    end
  end

end