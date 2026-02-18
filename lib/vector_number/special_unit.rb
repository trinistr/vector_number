# frozen_string_literal: true

class VectorNumber
  # Class for representing special (unique) units.
  #
  # There usually isn't much point in using these, aside from {VectorNumber::NUMERIC_UNITS}.
  # However, they can be helpful to denote units that aren't equal to any other object.
  #
  # +VectorNumber#to_s+ (and +inspect+) will use {#to_s} text instead of {#inspect} text
  # for these units by default, without a multiplication operator. However, consider
  # using customization of +VectorNumber#to_s+ instead if this is what you want.
  #
  # @since 0.6.0
  class SpecialUnit
    # Returns a new, unique unit, not equal to any other unit.
    #
    # @param unit [#to_s] name for {#inspect}
    # @param text [String] text for {#to_s}
    def initialize(unit, text = unit.to_s)
      @unit = unit
      @text = text
    end

    # Get predefined string representation of the unit.
    #
    # @return [String]
    def to_s
      @text
    end

    # Support for PP, outputs the same text as {#inspect}.
    #
    # @param pp [PP]
    # @return [void]
    #
    # @since <<next>>
    def pretty_print(pp)
      pp.text(inspect)
    end

    # Get string representation of the unit for debugging.
    #
    # @return [String]
    def inspect
      "unit/#{@unit}"
    end
  end
end
