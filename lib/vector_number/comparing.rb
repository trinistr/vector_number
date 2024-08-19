# frozen_string_literal: true

class VectorNumber
  # Methods for comparing with other numbers.
  module Comparing
    include ::Comparable

    # Compare to +other+ for equality.
    #
    # Values are considered equal if
    # - +other+ is a VectorNumber and it is +eql?+ to this one, or
    # - +other+ is a Numeric equal in value to this number.
    #
    # @param other [Object]
    # @return [Boolean]
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

    # @param other [Object]
    # @return [Boolean]
    def eql?(other)
      return true if equal?(other)

      if other.is_a?(VectorNumber)
        other.size == size && other.each_pair.all? { |u, c| @data[u] == c }
      else
        false
      end
    end

    # @note This method is not commutative with implementations in various Numeric subclasses,
    #   unless {NumericRefinements} is used.
    # @param other [Object]
    # @return [Integer, nil]
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
