require 'csv'

module WebCrawler::View
  class Plain < Base
    def format(item)
      item
    end
  end
end