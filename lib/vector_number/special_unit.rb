# frozen_string_literal: true

class VectorNumber
  # Class for representing special units.
  #
  # The public API consists of:
  # - +#==+/+#eql?+/+#equal?+ (from +Object+)
  # - +#hash+ (from +Object+)
  # - {#to_s}
  # - {#inspect}
  #
  # @since <<next>>
  class SpecialUnit
    # @api private
    # @param unit [#to_s] name for {#inspect}
    # @param text [String] text for {#to_s}
    def initialize(unit, text)
      @unit = unit
      @text = text
    end

    # Get predefined string representation of the unit.
    #
    # @return [String]
    def to_s
      @text
    end

    # Get string representation of the unit for debugging.
    #
    # @return [String]
    def inspect
      "unit/#{@unit}"
    end
  end
end
