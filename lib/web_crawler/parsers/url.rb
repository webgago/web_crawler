class WebCrawler::Parsers::Url

  attr_reader :host, :scheme

  def initialize(host, options = { })
    @scheme  = options[:secure] ? 'https' : 'http'
    @host    = URI.parse(normalize_host(host))
    @scheme  = @host.scheme
    @options = options
    set_current_page
  end

  def parse(response, &filter)
    (Hpricot(response.to_s) / "a").map do |a|
      normalize(a["href"]).tap do |url|
        url = filter.call(url) if url && filter
      end
    end.compact.uniq
  end

  def normalize(url)
    if url[/^(:?#{@host.scheme}|https|)\:\/\/#{@host.host}/]
      normalize_host(url)
    elsif url == '#'
      nil
    else
      (url[0] == '/' || url[0] == '?' || url[0] == '#') ? join(url).to_s : (@options[:same_host] ? nil : url)
    end
  end

  protected

  def set_current_page
    @current_url = join(@options[:page] || @options[:url] || @options[:path] || '/', @host)
  end

  def normalize_host(host, scheme = @scheme)
    host[0..3] == 'http' ? host : "#{scheme}://" + host
  end

  def join(request_uri, host = @current_url)
    return host.dup unless request_uri
    host.dup.tap do |u|
      path_with_query, anchor = request_uri.split('#')
      path, query = path_with_query.split('?')
      u.send(:set_fragment, anchor)
      u.send(:set_query, query) if query && !query.empty?
      u.send(:set_path, path) if path && !path.empty?
    end
  end

end