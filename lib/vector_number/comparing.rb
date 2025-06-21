# frozen_string_literal: true

class VectorNumber
  # Methods for comparing with other numbers.
  #
  # +Comparable+ is included for parity with numbers.
  # @example using Comparable methods
  #   VectorNumber[12] < 0 # => false
  #   VectorNumber[12, "a"] < 0 # ArgumentError
  #   (VectorNumber[12]..VectorNumber[15]).include?(13) # => true
  module Comparing
    # @since 0.2.0
    include ::Comparable

    # Compare to +other+ for equality.
    #
    # Values are considered equal if
    # - +other+ is a VectorNumber and it is +eql?+ to this one, or
    # - +other+ is a Numeric equal in value to this (real or complex) number.
    #
    # @example
    #   VectorNumber[3.13] == 3.13 # => true
    #   VectorNumber[1.4, 1.5i] == Complex(1.4, 1.5) # => true
    #   VectorNumber["a", "b", "c"] == VectorNumber["c", "b", "a"] # => true
    #   VectorNumber["a", 14] == 14 # => false
    #   VectorNumber["a"] == "a" # => false
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @since 0.2.0
    def ==(other)
      return true if eql?(other)

      case other
      when Numeric
        numeric?(2) && other.real == real && other.imaginary == imaginary
      else
        # Can't compare a number-like value to a non-number.
        false
      end
    end

    # Compare to +other+ for strict equality.
    #
    # Values are considered equal only if +other+ is a VectorNumber
    # and it has exactly the same units and coefficients, though possibly in a different order.
    #
    # Note that {#options} are not considered for equality.
    #
    # @example
    #   VectorNumber["a", "b", "c"].eql? VectorNumber["c", "b", "a"] # => true
    #   VectorNumber[3.13].eql? 3.13 # => false
    #   VectorNumber[1.4, 1.5i].eql? Complex(1.4, 1.5) # => false
    #   VectorNumber["a", 14].eql? 14 # => false
    #   VectorNumber["a"].eql? "a" # => false
    #
    # @param other [Object]
    # @return [Boolean]
    #
    # @since 0.1.0
    def eql?(other)
      return true if equal?(other)

      if other.is_a?(VectorNumber)
        other.size == size && other.each_pair.all? { |u, c| @data[u] == c }
      else
        false
      end
    end

    # Compare to +other+ and return -1, 0, or 1
    # if +self+ is less than, equal, or larger than +other+.
    #
    # @example
    #   VectorNumber[130] <=> 12 # => 1
    #   1 <=> VectorNumber[13] # => -1
    #   VectorNumber[12.1] <=> Complex(12.1, 0) # => 0
    #   # This doesn't work as expected without NumericRefinements:
    #   Complex(12.1, 0) <=> VectorNumber[12.1] # => nil
    #
    #   # Any non-real comparison returns nil:
    #   VectorNumber[12.1] <=> Complex(12.1, 1) # => nil
    #   VectorNumber[12.1i] <=> 2 # => nil
    #   VectorNumber["a"] <=> 2 # => nil
    #
    # @param other [Object]
    # @return [-1, 0, 1]
    # @return [nil] if +self+ or +other+ isn't a real number.
    #
    # @see Comparable
    # @see NumericRefinements
    #
    # @since 0.2.0
    def <=>(other)
      return nil unless numeric?(1)

      case other
      when VectorNumber
        other.numeric?(1) ? real <=> other.real : nil
      when Numeric
        other.imaginary.zero? ? real <=> other.real : nil
      else
        nil
      end
    end
  end
end
