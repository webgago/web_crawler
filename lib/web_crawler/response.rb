require 'mime/types'

module WebCrawler
  class Response
    extend ::Forwardable

    delegate [:http_version, :code, :message, :msg, :code_type, :[], :redirect_path, :redirect?] => '@response'

    attr_reader :url, :expire, :date, :cached

    def initialize(url, response)
      raise ArgumentError, "response must be a Net::HTTPResponse, but #{response.class} given" unless response.is_a? Net::HTTPResponse
      @url, @response = url, response
      @date = Time.parse(self['Date']) rescue Time.now
      @expire ||= Time.parse(self['Expires']) rescue Time.now
    end

    [:xml, :html, :json].each do |type|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{type}?
          mime_type.sub_type == '#{type}'
        end
      RUBY
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

    def mime_type
      MIME::Types[header['content-type']].first
    end

    def header
      @header ||= Hash[@response.to_hash.map(&:flatten)]
    end

    def body
      type, encoding = self['Content-Type'].split("=")
      @body ||= if encoding.upcase == 'UTF-8'
                  @response.body
                else
                  encode_body(encoding.upcase)
                end
    end

    alias :to_s :body

    def encode_body(from)
      require "iconv" unless defined?(Iconv)
      encoded = Iconv.iconv('UTF-8', from, @response.body).first
      if xml?
        encoded = encoded.gsub(/<\?xml version="(.*?)" encoding=".*?"\?>/, "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
      end
      encoded
    end

    def type
      @response.class
    end
  end
end
