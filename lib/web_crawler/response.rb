module WebCrawler
  class Response
    extend ::Forwardable

    delegate [:body, :http_version, :code, :message, :msg, :code_type, :[], :redirect_path, :redirect?] => '@response'

    attr_reader :url, :expire, :date, :cached

    def initialize(url, response)
      raise ArgumentError, "response must be a Net::HTTPResponse, but #{response.class} given" unless response.is_a? Net::HTTPResponse
      @url, @response = url, response
      @date = Time.parse(self['Date']) rescue Time.now
      @expire ||= Time.parse(self['Expires']) rescue Time.now
    end

    def set_cached_flag
      @cached = ' CACHED'
    end

    def foul?
      date >= expire
    end

    def success?
      @response.is_a? Net::HTTPSuccess
    end

    def failure?
      !success?
    end

    def inspect
      redirected = redirect? ? " redirect path: \"" + redirect_path.join(', ') + "\"" : ""
      "#<#{self.class}::0x#{self.object_id.to_s(16).rjust(14, '0')}#{@cached} " <<
          "#{type} #{code} #{message} #{@url}" <<
          "#{redirected}>"
    end

    alias :to_s :body

    def type
      @response.class
    end
  end
end
