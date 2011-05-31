class Thor
  module Hooks

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

    module InstanceMethods
      attr_reader :response

      def before_hooks
        self.class.before_hooks
      end

      def after_hooks
        self.class.after_hooks
      end

      # Invoke the given task if the given args.
      def invoke_task(task, *args) #:nodoc:
        self.class.run_hooks :before, self, task
        @task_result = super(task, *args)
        @task_result.tap do
          self.class.run_hooks :after, self, task
        end
      end
    end

    module ClassMethods
      def hooks
        @@hooks ||= { before: [], after: [] }
      end

      def before_hooks
        hooks[:before]
      end

      def after_hooks
        hooks[:after]
      end

      def before_action(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : { }
        check_hooks_options! options
        add_hook :before, args, options, &block
      end

      def after_action(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : { }
        check_hooks_options! options
        add_hook :after, args, options, &block
      end

      def render(*args, &block)
        after_action(*args) do
          block.call @task_result, @options
        end
      end

      def run_hooks(place, instance, task)
        hooks[place].each { |hook| self.run_hook(instance, task, hook) }
      end


      protected

      def check_hooks_options!(options)
        raise ArgumentError, <<-M.gsub(/^\s+/, '') if options.keys.include?(:only) && options.keys.include?(:except)
        both ":only" and ":except" given. You should use alone option ":only" or ":except"
        M
      end

      def add_hook(place, args, options, &block)
        options[:only]   ||= []
        options[:except] ||= []
        options[:only]   = [*options[:only]]
        options[:except] = [*options[:except]]
        hooks[place] << { block: block, options: options, args: args }
      end

      def run_hook(instance, task, hook)
        instance.instance_eval(&hook[:block]) if runnable?(task, hook)
      end

      def runnable?(task, hook)
        with_only   = hook[:options][:only].empty? || hook[:options][:only].include?(task.name.to_sym)
        with_except = !hook[:options][:except].include?(task.name.to_sym)
        with_only && with_except
      end
    end

  end
end