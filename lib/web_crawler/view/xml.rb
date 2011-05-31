module WebCrawler::View
  class Xml < Base

    self.default_options = { pretty: true }

    def render
      @options[:headers] ||= input.max_by(&:size).each_with_index.map { |_, index| "field_#{index+1}" }
      "<responses>#{pretty}#{super}</responses>"
    end

    def format(item)
      response_tag item.is_a?(Hash) ? item : Hash[@options[:headers].zip item]
    end

    protected

    def response_tag(hash)
      tag(:response) do
        hash.map do |tag, value|
          "<#{tag}>#{value}</#{tag}>"
        end.join
      end + pretty
    end

    def pretty
      @options[:pretty] ? "\n" : ""
    end

    def tag(name, value="", &block)
      value << block.call if block_given?
      unless value.empty?
        "<#{name}>#{value}</#{name}>"
      else
        "<#{name}/>"
      end
    end
  end
end
