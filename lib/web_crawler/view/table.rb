require 'csv'

module WebCrawler::View
  # Render a table.
  #
  # ==== Parameters
  # Array[Array[String, String, ...]]
  #
  # ==== Options
  # ident<Integer>:: Indent the first column by ident value.
  # colwidth<Integer>:: Force the first column to colwidth spaces wide.
  #
  class Table < Base

    def render
      format_table(@input)
    end

    protected

    def format_table(table)
      return if table.empty?

      formats, ident, colwidth = [], @options[:ident].to_i, @options[:colwidth]
      @options[:truncate] = terminal_width if @options[:truncate] == true

      formats << "%-#{colwidth + 2}s" if colwidth
      start = colwidth ? 1 : 0

      start.upto(table.first.length - 2) do |i|
        maxima ||= table.max { |a, b| a[i].size <=> b[i].size }[i].size
        formats << "%-#{maxima + 2}s"
      end

      formats[0] = formats[0].insert(0, " " * ident)
      formats << "%s"

      table.map do |row|
        sentence = ""

        row.each_with_index do |column, i|
          sentence << formats[i] % column.to_s
        end

        sentence = truncate(sentence, @options[:truncate]) if @options[:truncate]
        sentence
      end.join "\n"
    end

    def terminal_width
      if ENV['THOR_COLUMNS']
        result = ENV['THOR_COLUMNS'].to_i
      else
        result = unix? ? dynamic_width : 80
      end
      (result < 10) ? 80 : result
    rescue
      80
    end

    def truncate(string, width)
      if string.length <= width
        string
      else
        (string[0, width-3] || "") + "..."
      end
    end
  end
end