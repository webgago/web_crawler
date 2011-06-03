require "fileutils"

module WebCrawler::View
  class Runner < Base

    class WorkSpace
      # array of responses
      attr_accessor :responses
      attr_accessor :results

      def q
        exit
      end

      def returning(value)
        self.results = value  
      end

      def method_missing(meth, *args, &block)
        puts "\e[31m\e[1mError: method \"\e[0m\e[31m#{meth}\e[0m\e[31m\e[1m\" is missing\e[0m"
      end
    end

    def render
      unless File.exists? @options['run']
        @options['run'] = File.expand_path @options['run'], FileUtils.pwd
      end

      @work_space = WorkSpace.new
      @work_space.responses = input.freeze
      @work_space.results   = eval(File.open(@options['run'], 'r').read, @work_space.instance_eval("binding"), @options['run'])

      load_console! if @options['console']

      WebCrawler::View.factory(@options['original_format'], @work_space.results, @options).render
    end

    def load_console! 
      require "irb"
      IRB.init_config nil
      IRB.instance_exec do
        @CONF[:BACK_TRACE_LIMIT] = 1

        @CONF[:PROMPT][:SIMPLE] = { :PROMPT_I => "[\e[1m\e[31mWebCrawler::API\e[0m](%n)>> ",
                                    :PROMPT_N => "[\e[1m\e[31mWebCrawler::API\e[0m](%n)>> ",
                                    :PROMPT_S => "[\e[1m\e[31mWebCrawler::API\e[0m](%n)*",
                                    :PROMPT_C => "(%n)?> ",
                                    :RETURN   => "\e[90m#=> %s\n\e[0m" }

        @CONF[:PROMPT_MODE] = :SIMPLE
      end

      irb = IRB::Irb.new IRB::WorkSpace.new(@work_space)


      IRB.instance_exec { @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC] }
      IRB.instance_exec { @CONF[:MAIN_CONTEXT] = irb.context }


      trap("SIGINT") do
        irb.signal_handle
      end

      begin
        catch(:IRB_EXIT) do
          irb.eval_input
        end
      ensure
        IRB.irb_at_exit
      end
    end
  end
end