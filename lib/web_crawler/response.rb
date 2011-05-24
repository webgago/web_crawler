require 'forwardable'

module WebCrawler
  class Response
    extend ::Forwardable

    delegate [:body, :http_version, :code, :message, :msg, :code_type] => '@response'
    
    attr_reader :url
  
    def initialize(url, response)
      raise ArgumentError, 'response must be a Net::HTTPResponse' unless response.is_a? Net::HTTPResponse
      @url, @response = url, response
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