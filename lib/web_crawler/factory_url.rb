module WebCrawler
  #
  # p = FactoryUrl.new "http://www.somehost.com/:second/:first/", :first => 0..10, :second => "a".."z"
  # p.urls #=> ["http://www.somehost.com/a/1",
  #        #    "http://www.somehost.com/b/1",
  #        #    "http://www.somehost.com/c/1",
  #        #    ...
  #        #    "http://www.somehost.com/x/10",
  #        #    "http://www.somehost.com/y/10",
  #        #    "http://www.somehost.com/z/10/"]
  #
  # p = FactoryUrl.new "http://www.somehost.com/$1/$2?param=$3", 0..10, "a".."z", [3,7,34,876,92]
  # p.urls #=> ["http://www.somehost.com/1/a?param=3",
  #        #    "http://www.somehost.com/1/b?param=7",
  #        #    "http://www.somehost.com/1/c?param=34",
  #        #    ...
  #        #    "http://www.somehost.com/10/x?param=34",
  #        #    "http://www.somehost.com/10/y?param=876",
  #        #    "http://www.somehost.com/10/z?param=92"]
  #
  # p = FactoryUrl.new 0..10, "a".."z", [3,7,34,876,92] do |first, second, third|
  #   "http://www.somehost.com/#{first}/#{second}?param=#{third}"
  # end
  #
  class FactoryUrl
    include Enumerable

    attr_reader :urls, :params, :pattern

    def initialize(*args, &block)
      @options = args.extract_options!
      if block_given?
        @block = block
      else
        @pattern = args.shift
        raise ArgumentError, "first argument must be an url pattern(String)" unless pattern.is_a? String
      end
      
      if @options.empty?
        @params = normalize_arguments(args)
      else
        values, keys = @options.values.map(&:to_a), @options.keys
        values = values.shift.product(*values)
        @params = values.map{|a| Hash[keys.zip(a)]}
      end
    end

    def factory
      @urls ||= if pattern && params.first.is_a?(Hash)
                  params.map { |opts| pattern.gsub(/:([a-z_]+)/) { opts[$1.to_sym] } }
                elsif pattern
                  params.map { |opts| pattern.gsub(/\$(\d+)/) { opts[$1.to_i - 1] } }
                else
                  params.map { |opts| @block.call *opts }
                end
    end

    def each
      @urls = nil
      factory.each do |url|
        yield url
      end
    end

    protected
    def normalize_arguments(args)
      args = args.first if args.size == 1 && args.first.is_a?(Enumerable)
      args.shift if args.first.is_a? String
      params  = args.map { |arg| convert_to_a(arg) }
      @params = params.shift.product(*params)
    end

    def convert_to_a(arg)
      arg = arg.to_a rescue arg
      [*arg]
    end
  end
end