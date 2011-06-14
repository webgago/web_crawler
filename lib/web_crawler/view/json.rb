require 'json'

module WebCrawler::View
  class Json < Base
    def render
      input.to_json
    end
  end
end
