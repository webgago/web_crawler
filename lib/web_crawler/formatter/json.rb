require 'json'

module WebCrawler::Formatter
  class Json < Base
    def draw
      {responses: input}.to_json
    end
  end
end
