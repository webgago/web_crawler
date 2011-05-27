require "pathname"

module WebCrawler::CacheAdapter

  class File < Base

    attr_reader :dir

    def initialize(dir)
      @dir = Pathname.new dir
    end

    def put response
      response.tap { write(super) }
    end

    def get uri
      response = read(uri)
      expire!(response) if expired?(response)
      response
    end

    def exist? uri
      file(uri).exist?
    end

    def file(response_or_url)
      url = response_or_url.url rescue response_or_url
      dir.join(uri_to_filename(url))
    end

    def expire!(response)
      file(response).delete
    end

    protected

    def read(uri)
      Marshal.load(file(uri).read)
    end

    def write(response)
      file(response).open('w+') { |f| f << Marshal.dump(response) }
    end

    def uri_to_filename(uri)
      uri.to_s.gsub(/\W/, '_').gsub(/_+/, '_')
    end

  end

end