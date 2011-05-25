

module WebCrawler
  class Response
    extend ::Forwardable

    delegate [:body, :http_version, :code, :message, :msg, :code_type, :[]] => '@response'
    
    attr_reader :url, :expire, :date
  
    def initialize(url, response)
      raise ArgumentError, "response must be a Net::HTTPResponse, but #{response.class} given" unless response.is_a? Net::HTTPResponse
      @url, @response = url, response
      @date = Time.parse(self['Date']) rescue Time.now
      @expire ||= Time.parse(self['Expires']) rescue Time.now
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
      "#<#{self.class}::0x#{self.object_id.to_s(16).rjust(14, '0')} #{@response.class} #{@response.code} #{@response.message}>"
    end

    alias :to_s :body

  end
end