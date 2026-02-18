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
  # {.numeric_unit?}/{.special_unit?} can be used to check if a particular unit
  # requires different logic.
  #
  # @example
  #   VectorNumber[5, "s"].to_s # => "5 + 1⋅\"s\""
  #   VectorNumber["s", 5].to_s # => "1⋅\"s\" + 5"
  # @example with :mult argument
  #   VectorNumber[5, :s].to_s(mult: :asterisk) # => "5 + 1*:s"
  #   (-VectorNumber[5, :s]).to_s(mult: "~~~") # => "-5 - 1~~~:s"
  # @example with a block
  #   VectorNumber[5, :s].to_s { |k, v| "#{format("%+.0f", v)}%#{k}" } # => "+5%1+1%s"
  #   VectorNumber[5, :s].to_s(mult: :cross) { |k, v, i, op|
  #     "#{',' unless i.zero?}#{v}#{op+k.inspect unless k == VectorNumber::R}"
  #   } # => "5,1×:s"
  #
  # @param mult [Symbol, String]
  #   text to use between coefficient and unit,
  #   can be one of the keys in {MULT_STRINGS} or an arbitrary string
  # @yieldparam unit [Any]
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
  # This is similar to +Complex#inspect+ — it returns result of {#to_s} in round brackets.
  #
  # @example
  #   VectorNumber[5, :s].inspect # => "(5 + 1⋅:s)"
  #
  # @return [String]
  #
  # @see to_s
  def inspect
    return "(0)" if zero?

    "(#{build_string("⋅")})"
  end

  # Support for PP, outputs the same text as {#inspect}.
  #
  # @param pp [PP]
  # @return [void]
  #
  # @since <<next>>
  def pretty_print(pp) # rubocop:disable Metrics/AbcSize
    pp.text("(0)") and return if zero?

    pp.group(1, "(", ")") do
      # This should use `pp.fill_breakable`, but PrettyPrint::SingleLine doesn't support it.
      pp.seplist(@data, -> { fill_breakable(pp) }, :each_with_index) do |(unit, coefficient), i|
        pp.text("-") if coefficient.negative?
        unless i.zero?
          pp.text("+") if coefficient.positive?
          fill_breakable(pp)
        end
        pp.text(coefficient.abs.to_s)
        (SpecialUnit === unit) ? pp.text(unit.to_s) : pp.text("⋅#{unit.inspect}")
      end
    end
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

  # @param unit [Any]
  # @param coefficient [Numeric]
  # @param operator [String]
  # @return [String]
  def value_to_s(unit, coefficient, operator)
    if SpecialUnit === unit
      "#{coefficient}#{unit}"
    else
      "#{coefficient}#{operator}#{unit.inspect}"
    end
  end

  def fill_breakable(pp)
    pp.group { pp.breakable }
  end
end
