# frozen_string_literal: true

class VectorNumber
  # Methods for performing actual math.
  module Mathing
    # The coerce method provides support for Ruby type coercion.
    # Unlike most numeric types, VectorNumber can coerce *anything*.
    # @param other [Object]
    # @return [Array(VectorNumber, VectorNumber)]
    def coerce(other)
      case other
      when VectorNumber
        [other, self]
      else
        [new([other]), self]
      end
    end

    # Return self.
    # @return [VectorNumber]
    def +@
      self
    end

    # Return new vector with negated coefficients.
    # This preserves order of units.
    # @return [VectorNumber]
    def -@
      new(&:-@)
    end

    # Return new vector as a sum of this and other value.
    # This is analogous to {VectorNumber.[]}.
    # @param other [Object]
    # @return [VectorNumber]
    def +(other)
      new([self, other])
    end

    # Return new vector as a sum of this and negative of the other value.
    # This is analogous to {VectorNumber.[]}, but allows to negate anything.
    # @param other [Object]
    # @return [VectorNumber]
    def -(other)
      self + new([other], &:-@)
    end

    # Multiply all coefficients by a real number, returning new vector.
    # This effectively multiplies magnitude by the specified factor.
    # @param other [Integer, Float, Rational, BigDecimal]
    # @return [VectorNumber]
    # @raise [RangeError] if +other+ is not a number or is not a real number
    def *(other)
      raise RangeError, "can't multiply #{self} and #{other}" unless real_number?(other)

      other = other.real
      new { _1 * other }
    end

    # Divide all coefficients by a real number, returning new vector.
    # This effectively multiplies magnitude by reciprocal of the specified factor.
    # @param other [Integer, Float, Rational, BigDecimal]
    # @return [VectorNumber]
    # @raise [RangeError] if +other+ is not a number or is not a real number
    def /(other)
      raise RangeError, "can't divide #{self} by #{other}" unless real_number?(other)

      other = other.real
      # Prevent integer division, but without loss of accuracy.
      other = Rational(other) if other.is_a?(Integer)
      new { _1 / other }
    end
  end
end
