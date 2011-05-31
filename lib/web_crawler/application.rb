module WebCrawler
  class Application < CLI

    desc "test", "Test task"
    def test
    end

    desc "get <URL...>", "Get pages from passed urls"
    method_option :parser, type: :array, desc: "first item is a parser class, second item is a path to parser file"
    method_option 'same-host', type: :boolean, desc: "find urls with same host only"

    def get(url, *urls)
      urls.unshift url

      batch = BatchRequest.new(*urls, symbolized_options)
      batch.process
    end

    map 'show-urls' => :show_urls
    desc "show-urls <URL...>", "Get pages from passed urls"
    method_option 'same-host', type: :boolean, desc: "find urls with same host only"
    method_option 'cols', type: :numeric, desc: "output columns size"

    def show_urls(url, *urls)
      urls.unshift url
      batch          = BatchRequest.new(*urls, symbolized_options)
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

  end
end
