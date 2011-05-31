module WebCrawler::View
  class Plain < Base

    def render
      [*input].join "\n"
    end

  end
end