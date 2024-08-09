# frozen_string_literal: true

class VectorNumber
  # Methods for comparing with other numbers.
  module Comparing
    # Compare to +other+ for equality.
    #
    # Values are considered equal if
    # - +other+ is a VectorNumber and it has exactly the same units and coefficients, or
    # - +other+ is a Numeric equal in value to this number.
    #
    # @param other [Object]
    # @return [Boolean]
    def ==(other)
      return true if eql?(other)
      # Can't compare a number-like value to a non-number.
      return false unless other.is_a?(Numeric)

      numeric?(2) && other.real == real && other.imaginary == imaginary
    end

    # @param other [Object]
    # @return [Boolean]
    def eql?(other)
      return true if equal?(other)

      if other.is_a?(self.class)
        other.size == size && other.each_pair.all? { |u, c| @data[u] == c }
      else
        false
      end
    end
  end
end
