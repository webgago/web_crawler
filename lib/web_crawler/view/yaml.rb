require 'yaml'

module WebCrawler::View
  class Yaml < Base
    def render
      YAML.dump(input)
    end
  end
end
