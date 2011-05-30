require 'thor'
require 'thor/actions'
require 'pathname'
require 'web_crawler/cli/thor_hooks'
require 'web_crawler/cli/thor_inherited_options'
require 'web_crawler/cli/thor_view'

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

    before_action except: :help do
      @options = options.dup
      @options[:format] = 'json' if options[:json]
      @options[:format] = 'xml' if options[:xml]
      @options[:format] = 'csv' if options[:csv]
      @options[:format] = 'table' if options[:table]
      @options[:format] = 'plain' if options[:plain]
    end

    render except: :help do |response, options|
      default_options = {
          'csv' => { col_sep: "\t", in_group_of: 5 },
          'xml' => { pretty: true }
      }
      WebCrawler::View.factory(options[:format], response, default_options[options[:format]]).draw
    end


    def help(task = nil)
      if task
        self.class.task_help(shell, task)
      else
        self.class.help shell
      end
    end

    desc "test", "Test task"

    def test
    end

    desc "get <URL...>", "Get pages from passed urls"
    method_option :parser, type: :array, desc: "first item is a parser class, second item is a path to parser file"
    method_option 'same-host', type: :boolean, desc: "find urls with same host only"

    def get(url, *urls)
      urls.unshift url

      batch = BatchRequest.new(*urls, normalize_options(options))
      Follower.new(batch.process, same_host: options['same-host']).process(normalize_options(options)).map do |response|
        [response.url.to_s, response.type.to_s, response.code, response.cached]
      end
    end

    map 'show-urls' => :show_urls
    desc "show-urls <URL...>", "Get pages from passed urls"
    method_option 'same-host', type: :boolean, desc: "find urls with same host only"
    method_option 'cols', type: :numeric, desc: "output columns size"

    def show_urls(url, *urls)
      urls.unshift url
      batch = BatchRequest.new(*urls, normalize_options(options))
      options[:cols] ||= 1
      Follower.new(batch.process, same_host: options['same-host']).collect.first.in_groups_of(options[:cols], "")
    end

    desc "factory URL_PATTERN [params,...]", "Generate urls and run get action"
    inherited_method_options :get
    method_option :output, type: :boolean, desc: "show output and exit"
    method_option :list, type: :boolean, desc: "show output like a list and exit"

    def factory(pattern, *params)
      params.map! { |param| eval(param) }
      urls = FactoryUrl.new(pattern, params)
      puts options.inspect
      sep = options[:list] ? "\n" : ' '
      if options[:output] || options[:list]
        puts urls.factory.map { |u| u.inspect }.join(sep).gsub('"', "'")
      else
        get *urls.factory
      end
    end

    protected

    def normalize_options(options)
      options = Hash[options.keys.zip(options.values)]
      options.symbolize_keys
    end


  end
end
