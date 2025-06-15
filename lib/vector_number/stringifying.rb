# frozen_string_literal: true

class VectorNumber
  # Methods and options for string representation.
  module Stringifying
    # Predefined symbols for multiplication to display between unit and coefficient.
    #
    # @return [Hash{Symbol => String}]
    #
    # @since 0.1.0
    MULT_STRINGS = {
      asterisk: "*", # U+002A
      cross: "×", # U+00D7
      dot: "⋅", # U+22C5
      invisible: "⁢", # U+2062, zero-width multiplication operator
      space: " ",
      none: ""
    }.freeze

    # Get a string representation of the vector.
    #
    # @example
    #   VectorNumber[5, "s"].to_s # => "5 + 1⋅'s'"
    #   VectorNumber["s", 5].to_s # => "1⋅'s' + 5"
    # @example with +:mult+
    #   VectorNumber[5, "s"].to_s(mult: :asterisk) # => "5 + 1*'s'"
    #
    # @param mult [Symbol, String]
    #   text to use between coefficient and unit,
    #   can be one of the keys in {MULT_STRINGS} or an arbitrary string
    # @return [String]
    # @raise [ArgumentError]
    #   if +mult+ is not a String and is not in {MULT_STRINGS}'s keys
    #
    # @since 0.1.0
    def to_s(mult: options[:mult])
      return "0" if zero?

      result = +""
      each_with_index do |(unit, coefficient), index|
        if index.zero?
          result << "-" if coefficient.negative?
        else
          result << (coefficient.positive? ? " + " : " - ")
        end
        result << value_to_s(unit, coefficient.abs, mult:)
      end
      result
    end

    # Get a string representation of the vector.
    #
    # This is similar to +Complex#inspect+: it returns result of {#to_s} in round brackets.
    #
    # @example
    #   VectorNumber[5, "s"].inspect # => "(5 + 1⋅'s')"
    #
    # @return [String]
    #
    # @see to_s
    #
    # @since 0.1.0
    def inspect
      # TODO: Probably make this independent of options.
      "(#{self})"
    end

    private

    # @param unit [Object]
    # @param coefficient [Numeric]
    # @param mult [Symbol, String]
    # @return [String]
    # @raise [ArgumentError] if +mult+ is not in {MULT_STRINGS}'s keys
    #
    # @since 0.1.0
    def value_to_s(unit, coefficient, mult:)
      if !mult.is_a?(String) && !MULT_STRINGS.key?(mult)
        raise ArgumentError, "unknown key #{mult.inspect}", caller
      end

      case unit
      when R
        coefficient.to_s
      when I
        "#{coefficient}i"
      else
        unit = "'#{unit}'" if unit.is_a?(String)
        operator = mult.is_a?(String) ? mult : MULT_STRINGS[mult]
        "#{coefficient}#{operator}#{unit}"
      end
    end
  end
end
