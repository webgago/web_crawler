require 'csv'

module WebCrawler::Formatter
  class Plain < Base
    def format(item)
      item
    end
  end
end