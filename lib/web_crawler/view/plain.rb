require 'csv'

module WebCrawler::View
  class Plain < Base

    def render
      input.map { |i| format(i) }.join "\n"
    end

    def format(item)
      item
    end
  end
end