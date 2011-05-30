require 'json'

module WebCrawler::View
  class Json < Base
    def render
      {responses: input}.to_json
    end
  end
end
