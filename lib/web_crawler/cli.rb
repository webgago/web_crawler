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
    method_option :save, type: :boolean
    method_option :dir, type: :string

    def get(url, *urls)
      check_options!(options, 'save' => 'dir')
      urls.unshift url

      req = WebCrawler::Request.new *urls
      if options['save']
        puts req.response.inspect
        req.response.each do |(uri, res)|
          save uri, res, options
        end
      end
    end

    protected

    def save(url, res, options)
      path = Pathname.new options['dir']
      path.mkpath
      path = path.join(url.gsub(/[^\w]/, '_'))
      path.open('w+') { |f| f.write res.body }
    end

    def check_options!(options, rules)
      rules.each do |if_opt, then_opt|
        raise Thor::RequiredArgumentMissingError unless (options[if_opt] && options[then_opt])
      end
    end

  end
end
