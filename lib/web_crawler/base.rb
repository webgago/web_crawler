require "set"

module WebCrawler
  class Base
    class_attribute :targets, :logger, :mappers, :cache, :follower, :responses

    self.targets, self.logger, self.mappers = Set.new, WebCrawler.config.logger, []

    delegate :run, :to => :'self.class'

    class << self

      include ActiveSupport::Callbacks

      def run(format=nil, format_options={ })
        compile_targets
        self.responses = WebCrawler::BatchRequest.new(targets.to_a).process
        if format
          formated(process(responses), format, format_options)
        else
          process(responses)
        end
      end

      protected

      def after(&block)
        @after_callback = block
      end

      def compile_targets
        following    = targets.select { |target| target.is_a?(Array) && target.first.is_a?(Proc) }
        self.targets = targets - following

        following.each do |target|
          target.first.call(target.last)
        end
      end

      def log_to(logger_or_path)
        case logger_or_path
          when Logger
            WebCrawler.config.logger = self.logger = logger_or_path
          when nil
            WebCrawler.config.logger = self.logger = Logger.new('/dev/null')
          else
            WebCrawler.config.logger = self.logger = Logger.new(logger_or_path)
        end
      end

      def cache_to(path_or_cache_adapter)
        adapter = nil
        adapter = path_or_cache_adapter if path_or_cache_adapter.is_a? WebCrawler::CacheAdapter::Base
        adapter = WebCrawler::CacheAdapter::File.new(path_or_cache_adapter) if File.directory? path_or_cache_adapter

        WebCrawler.configure do
          config.cache.adapter = adapter
        end if adapter
      end

      def follow(*targets)
        options   = targets.extract_options!
        responses = WebCrawler::BatchRequest.new(targets).process
        self.target WebCrawler::Follower.new(responses, options).collect
      end

      def context(selector, name=selector, &block)
        mapper = WebCrawler::Parsers::Mapper.new(name, self, selector)
        if block.arity.zero?
          mapper.instance_exec(&block)
        else
          mapper.callback(&block)
        end
        self.mappers += [mapper]
      end

      def target(*targets, &block)
        options = targets.extract_options!
        unless options.empty?
          raise ArgumentError, 'target accept only one pattern if options given' if targets.size > 1
          targets = generate_urls(targets.first, options)
        end
        if block_given?
          self.targets << [block, targets]
        else
          self.targets += targets.flatten
        end
      end

      def generate_urls(pattern, options)
        WebCrawler::FactoryUrl.new(pattern, options).factory
      end

      def formated(data, format, options)
        require "active_support/core_ext/string"
        WebCrawler::View.factory(format, data, options).render
      end

      def process(responses)
        return responses.map(&:to_s) if mappers.empty?
        
        { }.tap do |results|
          mappers.each do |mapper|
            results[mapper.name] = responses.map do |response|
              mapper.collect(response)
            end.flatten
          end
        end
      end
    end

  end
end