require 'csv'

module WebCrawler::Formatter
  class CSV < Base
    def initialize(input, options = { })
      headers = options.delete(:headers) || input.select { |i| i.is_a? Hash }.max_by(&:size).keys
    rescue NoMethodError
    ensure
      input = input.dup.unshift(headers) unless headers.nil?
      super(input, options)
    end

    def format(item)
      values = item.respond_to?(:values) ? item.values : item.to_a
      values.to_csv(@options)
    end
  end
end