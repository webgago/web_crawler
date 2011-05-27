class Thor
  module InheritedOptions

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def option_to_hash(option)
        values = option.instance_variables.map { |v| option.instance_variable_get v }
        keys   = option.instance_variables.map { |sym| sym.to_s.sub('@', '') }
        Hash[keys.zip values]
      end

      def inherited_method_options(from_action, for_action = nil)
        tasks[from_action.to_s].options.each do |name, option|
          option_hash = option_to_hash(option).symbolize_keys
          option_hash.merge! for: for_action.to_s if for_action
          option_hash[:desc] = option_hash[:description]
          method_option name, option_hash
        end
      end
    end

  end
end