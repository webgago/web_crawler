require 'thor'
require 'thor/actions'
require 'pathname'

module WebCrawler
  class CLI < Thor
    include Thor::Actions

    default_task :help

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
    method_option :cached, type: :boolean, desc: "use cached requests"

    def get(url, *urls)
      urls.unshift url

      batch  = BatchRequest.new(*urls, normalize_options(options))
      result = batch.process

      puts result.inspect
#      say "Start fetching for urls: #{urls.join(', ')}"
#      puts batch.response.inspect
#
#      if options['parser']
#        require options['parser'][1] if options['parser'][1]
#        print_table result.first, colwidth: 350
#        print_table [["Links size", result.first.size]], colwidth: 350
#      end


    end

    desc "factory URL_PATTERN [params,...]", "Get pages from passed url pattern and params for generate urls"
    method_option :cached, type: :boolean, desc: "use cached requests"
    def factory(pattern, *params)
      params.map! { |param| eval(param) }
      urls = FactoryUrl.new(pattern, params)
      puts [urls.factory && urls].inspect
      batch = BatchRequest.new(urls.factory, normalize_options(options))
      result = batch.process

      puts [result.size, result].inspect
    end

    protected

    def normalize_options(options)
      options = Hash[options.keys.zip(options.values)]
      options.symbolize_keys
    end

  end
end
