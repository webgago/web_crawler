module WebCrawler::Utility
  extend self

  # By default, +camelize+ converts strings to UpperCamelCase. If the argument to +camelize+
  # is set to <tt>:lower</tt> then +camelize+ produces lowerCamelCase.
  #
  # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  # Examples:
  #   "active_record".camelize                # => "ActiveRecord"
  #   "active_record".camelize(:lower)        # => "activeRecord"
  #   "active_record/errors".camelize         # => "ActiveRecord::Errors"
  #   "active_record/errors".camelize(:lower) # => "activeRecord::Errors"
  #
  # As a rule of thumb you can think of +camelize+ as the inverse of +underscore+,
  # though there are cases where that does not hold:
  #
  #   "SSLError".underscore.camelize # => "SslError"
  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end

  # Makes an underscored, lowercase form from the expression in the string.
  #
  # Changes '::' to '/' to convert namespaces to paths.
  #
  # Examples:
  #   "ActiveRecord".underscore         # => "active_record"
  #   "ActiveRecord::Errors".underscore # => active_record/errors
  #
  # As a rule of thumb you can think of +underscore+ as the inverse of +camelize+,
  # though there are cases where that does not hold:
  #
  #   "SSLError".underscore.camelize # => "SslError"
  def underscore(camel_cased_word)
    word = camel_cased_word.to_s.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  # Replaces underscores with dashes in the string.
  #
  # Example:
  #   "puni_puni" # => "puni-puni"
  def dasherize(underscored_word)
    underscored_word.gsub(/_/, '-')
  end

  # Removes the module part from the expression in the string.
  #
  # Examples:
  #   "ActiveRecord::CoreExtensions::String::Inflections".demodulize # => "Inflections"
  #   "Inflections".demodulize                                       # => "Inflections"
  def demodulize(class_name_in_module)
    class_name_in_module.to_s.gsub(/^.*::/, '')
  end
end