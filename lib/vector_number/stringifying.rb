# frozen_string_literal: true

class VectorNumber
  # Predefined symbols for multiplication to display between unit and coefficient.
  #
  # @return [Hash{Symbol => String}]
  MULT_STRINGS = {
    asterisk: "*", # U+002A
    cross: "×", # U+00D7
    dot: "⋅", # U+22C5
    invisible: "⁢", # U+2062, zero-width multiplication operator
    space: " ",
    none: "",
  }.freeze

  # @group Miscellaneous methods

  # Return string representation of the vector suitable for output.
  #
  # An optional block can be supplied to provide customized substrings
  # for each unit and coefficient pair.
  # Care needs to be taken in handling +VectorNumber::R+ and +VectorNumber::I+ units.
  # {.numeric_unit?} can be used to check if a particular unit needs special handling.
  #
  # @example
  #   VectorNumber[5, "s"].to_s # => "5 + 1⋅\"s\""
  #   VectorNumber["s", 5].to_s # => "1⋅\"s\" + 5"
  # @example with :mult argument
  #   VectorNumber[5, :s].to_s(mult: :asterisk) # => "5 + 1*s"
  #   (-VectorNumber[5, :s]).to_s(mult: "~~~") # => "-5 - 1~~~s"
  # @example with a block
  #   VectorNumber[5, :s].to_s { |k, v| "#{format("%+.0f", v)}%#{k}" } # => "+5%1+1%s"
  #   VectorNumber[5, :s].to_s(mult: :cross) { |k, v, i, op|
  #     "#{',' unless i.zero?}#{v}#{op+k.to_s unless k == VectorNumber::R}"
  #   } # => "5,1×s"
  #
  # @param mult [Symbol, String]
  #   text to use between coefficient and unit,
  #   can be one of the keys in {MULT_STRINGS} or an arbitrary string
  # @yieldparam unit [Object]
  # @yieldparam coefficient [Numeric]
  # @yieldparam index [Integer]
  # @yieldparam operator [String]
  # @yieldreturn [String] a string for this unit and coefficient
  # @return [String]
  # @raise [ArgumentError]
  #   if +mult+ is not a String and is not in {MULT_STRINGS}'s keys
  def to_s(mult: :dot, &block)
    if !(String === mult) && !MULT_STRINGS.key?(mult)
      raise ArgumentError, "unknown key #{mult.inspect}", caller
    end
    return "0" if zero?

    operator = (String === mult) ? mult : MULT_STRINGS[mult]
    build_string(operator, &block)
  end

  # Return string representation of the vector suitable for display.
  #
  # This is similar to +Complex#inspect+: it returns result of {#to_s} in round brackets.
  #
  # @example
  #   VectorNumber[5, :s].inspect # => "(5 + 1⋅s)"
  #
  # @return [String]
  #
  # @see to_s
  def inspect
    "(#{self})"
  end

  private

  # @param operator [String]
  # @return [String]
  def build_string(operator)
    result = +""
    each_with_index do |(unit, coefficient), index|
      if block_given?
        result << (yield unit, coefficient, index, operator).to_s
      else
        if index.zero?
          result << "-" if coefficient.negative?
        else
          result << (coefficient.positive? ? " + " : " - ")
        end
        result << value_to_s(unit, coefficient.abs, operator)
      end
    end
    result
  end

  # @param unit [Object]
  # @param coefficient [Numeric]
  # @param operator [String]
  # @return [String]
  def value_to_s(unit, coefficient, operator)
    if NUMERIC_UNITS.include?(unit)
      "#{coefficient}#{unit}"
    else
      "#{coefficient}#{operator}#{unit.inspect}"
    end
  end
end
