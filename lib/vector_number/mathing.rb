# frozen_string_literal: true

class VectorNumber
  # Methods for performing actual math.
  module Mathing
    # The coerce method provides support for Ruby type coercion.
    #
    # Unlike most numeric types, VectorNumber can coerce *anything*.
    #
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
    #
    # @return [VectorNumber]
    alias +@ itself

    # Return new vector with negated coefficients.
    #
    # This preserves order of units.
    #
    # @return [VectorNumber]
    def -@
      new(&:-@)
    end

    alias neg -@

    # Return new vector as a sum of this and other value.
    #
    # This is analogous to {VectorNumber.[]}.
    #
    # @param other [Object]
    # @return [VectorNumber]
    def +(other)
      new([self, other])
    end

    alias add +

    # Return new vector as a sum of this and additive inverse of the other value.
    #
    # This is implemented through {#+} and {#-@}.
    #
    # @param other [Object]
    # @return [VectorNumber]
    def -(other)
      self + new([other], &:-@)
    end

    alias sub -

    # Multiply all coefficients by a real number, returning new vector.
    #
    # This effectively multiplies magnitude by the specified factor.
    #
    # @param other [Integer, Float, Rational, BigDecimal, VectorNumber]
    # @return [VectorNumber]
    # @raise [RangeError] if +other+ is not a number or +other+ can't be multiplied by this one
    def *(other)
      if real_number?(other)
        other = other.real
        # @type var other: Float
        new { _1 * other }
      elsif real_number?(self) && other.is_a?(self.class)
        # @type var other: untyped
        other * self
      else
        raise RangeError, "can't multiply #{self} and #{other}"
      end
    end

    alias mult *

    # Divide all coefficients by a real number, returning new vector.
    #
    # This effectively multiplies magnitude by reciprocal of +other+.
    # @note This method never does integer division.
    #
    # @param other [Integer, Float, Rational, BigDecimal, VectorNumber]
    # @return [VectorNumber]
    # @raise [RangeError] if +other+ is not a number or is not a real number
    # @raise [ZeroDivisionError] if +other+ is zero
    def /(other)
      check_divisibility(other)

      other = other.real
      # Prevent integer division, but without loss of accuracy.
      other = Rational(other) if other.integer?
      # @type var other: Float
      new { _1 / other }
    end

    alias quo /

    # Divide all coefficients by a real number using +fdiv+,
    # returning new vector with Float coefficients.
    #
    # @param other [Integer, Float, Rational, BigDecimal, VectorNumber]
    # @return [VectorNumber]
    # @raise [RangeError] if +other+ is not a number or is not a real number
    # @raise [ZeroDivisionError] if +other+ is zero
    def fdiv(other)
      check_divisibility(other)

      other = other.real
      new { _1.fdiv(other) }
    end

    # Divide all coefficients by +other+, rounding results with {#floor}.
    #
    # This is requal to +(self / other).floor+.
    #
    # @see #divmod
    # @see #%
    #
    # @param other [Integer, Float, Rational, BigDecimal, VectorNumber]
    # @return [VectorNumber]
    # @raise [RangeError] if +other+ is not a number or is not a real number
    # @raise [ZeroDivisionError] if +other+ is zero
    def div(other)
      check_divisibility(other)

      other = other.real
      new { _1.div(other) }
    end

    # Return the modulus of dividing self by +other+ as a vector.
    #
    # This is equal to +self - other * (self/other).floor+.
    #
    # @see #divmod
    # @see #div
    # @see #remainder for alternative
    # @see Numeric#% for examples
    #
    # @param other [Integer, Float, Rational, BigDecimal, VectorNumber]
    # @return [VectorNumber]
    # @raise [RangeError] if +other+ is not a number or is not a real number
    # @raise [ZeroDivisionError] if +other+ is zero
    def %(other)
      check_divisibility(other)

      other = other.real
      new { _1 % other }
    end

    alias modulo %

    # Return the quotient and modulus of dividing self by +other+.
    # There is no performance benefit compared to calling {#div} and {#%} separately.
    #
    # @see #div
    # @see #%
    #
    # @param other [Integer, Float, Rational, BigDecimal, VectorNumber]
    # @return [Array(VectorNumber, VectorNumber)]
    # @raise [RangeError] if +other+ is not a number or is not a real number
    # @raise [ZeroDivisionError] if +other+ is zero
    def divmod(other)
      [div(other), modulo(other)]
    end

    # Return the remainder of dividing self by +other+ as a vector.
    #
    # This is equal to +self - other * (self/other).truncate+.
    #
    # @see #% for alternative
    # @see Numeric#remainder for examples
    #
    # @param other [Integer, Float, Rational, BigDecimal, VectorNumber]
    # @return [VectorNumber]
    # @raise [RangeError] if +other+ is not a number or is not a real number
    # @raise [ZeroDivisionError] if +other+ is zero
    def remainder(other)
      check_divisibility(other)

      other = other.real
      new { _1.remainder(other) }
    end

    private

    def check_divisibility(other)
      unless real_number?(other)
        raise RangeError, "can't divide #{self} by #{other.inspect}", caller
      end
      raise ZeroDivisionError, "divided by 0", caller if other.zero?
    end
  end
end
