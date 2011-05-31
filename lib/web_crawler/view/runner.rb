require "fileutils"

module WebCrawler::View
  class Runner < Base

    module Space
      extend self
      attr_accessor :responses
    end

    def render
      unless File.exists? @options['run']
        @options['run'] = File.expand_path @options['run'], FileUtils.pwd
      end

      Space.responses = input.freeze
      Space.module_eval(File.open(@options['run'], 'r').read)
    end
  end
end