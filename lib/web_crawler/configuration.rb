require "logger"

module WebCrawler
  class BaseConfiguration

    def initialize(options = {})
      @@options ||= {}
      @@options.merge! options
    end

    def respond_to?(name)
      super || @@options.key?(name.to_sym)
    end

    def config
      self
    end
    
    private

    def method_missing(name, *args, &blk)
      if name.to_s =~ /=$/
        @@options[$`.to_sym] = args.first
      elsif @@options.key?(name)
        @@options[name]
      else
        super
      end
    end
  end

  class Configuration < BaseConfiguration

    attr_accessor :cache_adapter, :log_level, :logger, :root, :cache

    def root
      @root ||= FileUtils.pwd
    end

    def cache_adapter
      @cache_adapter ||= begin
        if File.exist?("#{root}/tmp/cache/")
          WebCrawler::CacheAdapter::File.new "#{root}/tmp/cache/"
        else
          WebCrawler::CacheAdapter::Memory.new
        end
      end
    end

    def cache(&block)
      @cache ||= BaseConfiguration.new expire_within: 60
      if block_given?
        @cache.instance_eval(block)
      else
        @cache
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT).tap do |log|
       log.level = Logger.const_get log_level.to_s.upcase
      end
    end

    def log_level
      @log_level ||= :debug
    end

  end

  module Configurable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def configure(&block)
        module_eval(&block)
      end

      def config
        @config ||= Configuration.new
      end

    end
  end
end
