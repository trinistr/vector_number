# frozen_string_literal: true

class VectorNumber
  # Methods for comparing with other numbers.
  module Comparing
    # @since 0.2.0
    include ::Comparable

    # Compare to +other+ for equality.
    #
    # Values are considered equal if
    # - +other+ is a VectorNumber and it is +eql?+ to this one, or
    # - +other+ is a Numeric equal in value to this (real or complex) number.
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
    # and it has exactly the same units and coefficients,
    # though possibly in a different order.
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
    # @param other [Object]
    # @return [-1, 0, 1]
    # @return [nil] if +self+ or +other+ isn't a real number.
    #
    # @see Comparable Comparable for comparison methods
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
