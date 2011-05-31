require 'thor'
require 'thor/actions'
require 'pathname'
require 'web_crawler/cli/thor_hooks'
require 'web_crawler/cli/thor_inherited_options'

module WebCrawler
  class CLI < Thor
    include Thor::Actions
    include Thor::Hooks
    include Thor::InheritedOptions

    default_task :help

    class_option :format, type: :string, desc: "output format [json, xml, csv]", default: 'plain'
    class_option :json, type: :boolean, desc: "json output format. shortcut for --format json"
    class_option :xml, type: :boolean, desc: "xml output format. shortcut for --format xml"
    class_option :csv, type: :boolean, desc: "csv output format. shortcut for --format csv"
    class_option :table, type: :boolean, desc: "table output format. shortcut for --format table"
    class_option :cached, type: :boolean, desc: "use cached requests. if ./tmp/cache exists use it for cache files"
    class_option :follow, type: :boolean, desc: "follow to urls on the pages"
    class_option :run, type: :string, desc: "run custom script with api access"
    class_option :console, type: :boolean, desc: "run irb console after execution"
    class_option :log, type: :string, desc: "log file path"

    before_action except: :help do
      @options = options.dup
      @options[:format] = 'json' if options[:json]
      @options[:format] = 'xml' if options[:xml]
      @options[:format] = 'csv' if options[:csv]
      @options[:format] = 'table' if options[:table]
      @options[:format] = 'plain' if options[:plain]

      @options[:original_format] = @options[:format] if options[:run]
      @options[:format] = 'runner' if options[:run]


      WebCrawler.config.logger = Logger.new(@options['log']) if @options['log']
      WebCrawler.config.logger.level           = Logger::DEBUG
      WebCrawler.config.logger.datetime_format = "%d-%m-%Y %H:%M:%S"
      WebCrawler.config.severity_colors        = { 'DEBUG' => :magenta,
                                                   'INFO'  => :green,
                                                   'WARN'  => :blue,
                                                   'ERROR' => :red,
                                                   'FATAL' => :red,
                                                   'ANY'   => :yellow }

      WebCrawler.config.logger.formatter = proc { |severity, datetime, _, msg|
        color = WebCrawler.config.severity_colors[severity]

        send(color, ("[#{severity}] ").ljust(8)) << "[#{datetime}] " << "pid #{$$} " << "-- #{msg}\n"
      }
    end

    render except: :help do |response, options|
      WebCrawler::View.factory(options[:format], response, options).draw
    end


    def help(task = nil)
      if task
        self.class.task_help(shell, task)
      else
        self.class.help shell
      end
    end

    protected

    def color(text, color_code)
      "#{color_code}#{text}\e[0m"
    end

    def bold(text)
      color(text, "\e[1m")
    end

    def white(text)
      color(text, "\e[37m")
    end

    def green(text)
      color(text, "\e[32m")
    end

    def red(text)
      color(text, "\e[31m")
    end

    def magenta(text)
      color(text, "\e[35m")
    end

    def yellow(text)
      color(text, "\e[33m")
    end

    def blue(text)
      color(text, "\e[34m")
    end

    def grey(text)
      color(text, "\e[90m")
    end

    def short_padding
      '  '
    end

    def long_padding
      '     '
    end

    def logger
      WebCrawler.logger
    end

    def symbolized_options
      @symbolized_options ||= Hash[@options.keys.zip(@options.values)].symbolize_keys
    end

  end
end
