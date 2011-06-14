require 'csv'

module WebCrawler::View
  class Csv < Base
    def initialize(input, options = { })
      in_group_of_num = options.delete(:in_group_of)
      input = input.first.in_groups_of(in_group_of_num) if in_group_of_num && input.size == 1
      headers = options.delete(:headers) || input.select { |i| i.is_a? Hash }.max_by(&:size).keys
    rescue NoMethodError
    ensure
      input = input.dup.unshift(headers) unless headers.nil?
      super(input, options)
    end

    def format(item)
      values = item.respond_to?(:values) ? item.values : item.to_a
      values.to_csv(@options[:csv] || {})
    end
  end
end