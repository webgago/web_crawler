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

    desc "get <URL...>", "Get pages from passed urls"
    method_option :parser, type: :array, desc: "first item is a parser class, second item is a path to parser file"
    def get(url, *urls)
      urls.unshift url

      batch = WebCrawler::BatchRequest.new(*urls, handler: options['parser'].first)
      result = batch.process

      say "Start fetching for urls: #{urls.join(', ')}"
      puts batch.response.inspect

      if options['parser']
        require options['parser'][1] if options['parser'][1]
        print_table result.first, colwidth: 350
        print_table [["Links size", result.first.size]], colwidth: 350
      end


    end

  end
end
