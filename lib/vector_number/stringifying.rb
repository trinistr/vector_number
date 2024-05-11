# frozen_string_literal: true

class VectorNumber
  # Methods and options for string representation.
  module Stringifying
    # Predefined symbols for multiplication to display between unit and coefficient.
    # @return [Hash{Symbol => String}]
    MULT_STRINGS = {
      asterisk: "*", # U+002A
      cross: "×", # U+00D7
      dot: "⋅", # U+22C5
      invisible: "⁢", # U+2062, zero-width multiplication operator
      space: " ",
      none: ""
    }.freeze

    # @param mult [Symbol, String]
    #   text to use between coefficient and unit,
    #   can be one of the keys in {MULT_STRINGS} or an arbitrary string
    # @return [String]
    # @raise [ArgumentError] if +mult+ is not in {MULT_STRINGS}'s keys
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

    # @return [String]
    def inspect
      "(#{self})"
    end

    private

    # @param unit [Object]
    # @param coefficient [Numeric]
    # @param mult [Symbol, String]
    # @return [String]
    # @raise [ArgumentError] if +mult+ is not in {MULT_STRINGS}'s keys
    def value_to_s(unit, coefficient, mult:)
      raise ArgumentError, "unknown key :#{mult}", caller if mult.is_a?(Symbol) && !MULT_STRINGS.key?(mult)

      case unit
      when 1
        return coefficient.to_s
      when I
        return "#{coefficient}i"
      end

      unit = "'#{unit}'" if unit.is_a?(String)
      operator = mult.is_a?(String) ? mult : MULT_STRINGS[mult]
      "#{coefficient}#{operator}#{unit}"
    end
  end
end
