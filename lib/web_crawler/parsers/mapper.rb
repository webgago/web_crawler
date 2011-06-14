class WebCrawler::Parsers::Mapper

  class Filter
    def initialize(method, context)
      @method, @context = method, context
    end

    def call(*args, &blk)
      return @context.send(@method, *args, &blk) if @method.is_a? Symbol
      return @method.call(*args, &blk) if @method.respond_to? :call
      return args.size == 1 ? args.first : args if @method.nil?
      raise ArgumentError, "#{@method} must be a Symbol or Object which respond with in :call or nil"
    end
  end

  class Map
    cattr_accessor :default_options
    self.default_options = { :on => :inner_text }

    def initialize(selector, binding, options, &block)
      @selector, @options = selector, self.class.default_options.merge(options)
      @binding = binding
      @block   = block
    end

    def with_block?
      @block.present?
    end

    def element
      @selector
    end

    def in(context)
      context.search(element).each do |el|
        yield el, @block.call
      end
    end

    def on
      @options[:on]
    end

    def to(context)
      @options[:to].respond_to?(:call) ? @options[:to].call(context) : @options[:to]
    end

    def filter
      @filter ||= Filter.new(@options[:filter], @binding)
    end

    def call(context)
      value = context.search(element)
      value = value.send(*on) if on.present?
      filter.call(value)
    end
  end

  attr_reader :selector, :element, :mapping, :klass, :name

  def initialize(name, binding, selector)
    @name     = name
    @binding  = binding
    @selector = selector
    @mapping  = { }
  end

  def callback(&block)
    if block_given?
      @callback = block
    else
      @callback
    end
  end

  def build_map(selector, options = { })
    Map.new(selector, @binding, options)
  end

  def map(selector, options = { }, &block)
    @mapping[selector] = Map.new(selector, @binding, options, &block)
  end

  def collect(response)
    doc = Hpricot(response.to_s, :xml => response.xml?)
    [].tap do |collected|
      doc.search(selector).each do |context|
        collected << { }
        collect_with_mapping(context, collected) unless mapping.empty?
        collect_with_callback(context, collected) if callback
      end
    end
  end

  protected

  def collect_with_mapping(context, collected)
    mapping.each_value do |map|
      if map.with_block?
        map.in(context) do |element, sub_map|
          collected.last[sub_map.to(element)] = sub_map.call(element)
        end
      else
        collected.last[map.to(context)] = map.call(context)
      end
    end
  end

  def collect_with_callback(context, collected)
    callback.call(context).each do |key, value|
      collected.last[key] = value
    end
  end
end