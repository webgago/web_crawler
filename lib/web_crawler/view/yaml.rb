require 'yaml'

module WebCrawler::View
  class Yaml < Base
    def render
      YAML.dump(responses: input)
    end
  end
end
