require 'json'

module WebCrawler::Formatter
  class JSON < Base
    def process
      {responses: input}.to_json
    end
  end
end
