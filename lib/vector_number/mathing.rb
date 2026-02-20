# frozen_string_literal: true

class VectorNumber
  # @group Arithmetic operations
  #
  # All operators (like +*+) have aliases (like +mult+)
  # to make method chaining easier and more natural.

  # The coerce method provides support for Ruby type coercion.
  #
  # Unlike other numeric types, VectorNumber can coerce *anything*.
  #
  # @example
  #   VectorNumber["a"].coerce(5) # => [(5), (1⋅"a")]
  #   VectorNumber[7].coerce([]) # => [(1⋅[]), (7)]
  #   VectorNumber["a"] + 5 # => (1⋅"a" + 5)
  #   # Direct reverse coercion doesn't work, but Numeric types know how to call #coerce:
  #   5.coerce(VectorNumber["a"]) # RangeError
  #   5 + VectorNumber["a"] # => (5 + 1⋅"a")
  #
  # @param other [Any]
  # @return [Array(VectorNumber, VectorNumber)]
  #
  # @since 0.2.0
  def coerce(other)
    case other
    when VectorNumber
      [other, self]
    else
      [new([other]), self]
    end
  end

  # Return new vector with negated coefficients (additive inverse).
  #
  # @example
  #   -VectorNumber[12, "i"] # => (-12 - 1⋅"i")
  #   VectorNumber["a", "b", "a"].neg # => (-2⋅"a" - 1⋅"b")
  #   -VectorNumber["a"] + VectorNumber["a"] # => (0)
  #
  # @return [VectorNumber]
  #
  # @since 0.2.0
  def -@
    new(&:-@)
  end

  # @since 0.3.0
  alias neg -@

  # Return new vector as a sum of this and +other+ value.
  # This is analogous to {VectorNumber.[]}.
  #
  # @example
  #   VectorNumber[5] + 10 # => (15)
  #   VectorNumber["a"].add(VectorNumber["b"]) # => (1⋅"a" + 1⋅"b")
  #   VectorNumber["a"] + "b" # => (1⋅"a" + 1⋅"b")
  # @example numeric types can be added in reverse
  #   10 + VectorNumber[5] # => (15)
  #   10 + VectorNumber["a"] # => (10 + 1⋅"a")
  #
  # @param other [Any]
  # @return [VectorNumber]
  #
  # @since 0.2.0
  def +(other)
    new([self, other])
  end

  # @since 0.3.0
  alias add +

  # Return new vector as a sum of this and additive inverse of +other+ value.
  #
  # This is implemented through {#+} and {#-@}.
  #
  # @example
  #   VectorNumber[5] - 3 # => (2)
  #   VectorNumber["a"].sub(VectorNumber["b"]) # => (1⋅"a" - 1⋅"b")
  #   VectorNumber["a"] - "b" # => (1⋅"a" - 1⋅"b")
  # @example numeric types can be subtracted in reverse
  #   3 - VectorNumber[5] # => (-2)
  #   3 - VectorNumber["a"] # => (3 - 1⋅"a")
  #
  # @param other [Any]
  # @return [VectorNumber]
  #
  # @since 0.2.0
  def -(other)
    new([self, new([other], &:-@)])
  end

  # @since 0.3.0
  alias sub -

  # Multiply all coefficients by a real +other+, returning new vector scaled by +other+.
  #
  # This effectively multiplies {#magnitude} by +other+.
  #
  # @example
  #   VectorNumber[5] * 2 # => (10)
  #   VectorNumber["a", "b", 6].mult(2) # => (2⋅"a" + 2⋅"b" + 12)
  #   VectorNumber["a"] * VectorNumber[2] # => (2⋅"a")
  #   # Can't multiply by a non-real:
  #   VectorNumber["a"] * VectorNumber["b"] # RangeError
  # @example numeric types can be multiplied in reverse
  #   2 * VectorNumber[5] # => (10)
  #   2 * VectorNumber["a"] # => (2⋅"a")
  #
  # @param other [Numeric, VectorNumber]
  # @return [VectorNumber]
  # @raise [RangeError] if +other+ is not a number or +other+ can't be multiplied by this one
  #
  # @since 0.2.1
  def *(other)
    if real_number?(other)
      other = other.real
      # @type var other: Float
      new { _1 * other }
    elsif real_number?(self) && VectorNumber === other
      # @type var other: untyped
      other * self
    else
      raise RangeError, "can't multiply #{self} and #{other}"
    end
  end

  # @since 0.3.0
  alias mult *

  # Divide all coefficients by a real +other+, returning new vector scaled by reciprocal of +other+.
  #
  # This effectively divides {#magnitude} by +other+.
  # @note This method never does integer division.
  #
  # @example
  #   VectorNumber[10] / 2 # => (5)
  #   VectorNumber["a", "b", 6].quo(2) # => ((1/2)⋅"a" + (1/2)⋅"b" + (3/1))
  #   VectorNumber["a"] / VectorNumber[2] # => ((1/2)⋅"a")
  #   # Can't divide by a non-real:
  #   VectorNumber["a"] / VectorNumber["b"] # RangeError
  # @example numeric types can be divided in reverse
  #   2 / VectorNumber[10] # => ((1/5))
  #   # Can't divide by a non-real:
  #   2 / VectorNumber["a"] # RangeError
  #
  # @param other [Numeric, VectorNumber]
  # @return [VectorNumber]
  # @raise [RangeError] if +other+ is not a number or is not a real number
  # @raise [ZeroDivisionError] if +other+ is zero
  #
  # @since 0.2.1
  def /(other)
    check_divisibility(other)

    other = other.real
    # Prevent integer division, but without loss of accuracy.
    other = Rational(other) if other.integer?
    # @type var other: Float
    new { _1 / other }
  end

  # @since 0.2.6
  alias quo /
  # to fix syntax highlighting: /

  # Divide all coefficients by a real +other+ using +fdiv+,
  # returning new vector with decimal coefficients.
  #
  # There isn't much benefit to this method, as {#/} doesn't do integer division,
  # but it is provided for consistency.
  #
  # @example
  #   VectorNumber[10].fdiv(2) # => (5.0)
  #   VectorNumber["a", "b", 6].fdiv(2) # => (0.5⋅"a" + 0.5⋅"b" + 3.0)
  #   VectorNumber["a"].fdiv(VectorNumber[2]) # => (0.5⋅"a")
  #   # Can't divide by a non-real:
  #   VectorNumber["a"].fdiv(VectorNumber["b"]) # RangeError
  # @example reverse division may return non-vector results
  #   2.fdiv(VectorNumber[10]) # => 0.2 (Float)
  #   2.0.fdiv(VectorNumber[10]) # => (0.2) (VectorNumber)
  #
  # @param other [Numeric, VectorNumber]
  # @return [VectorNumber]
  # @raise [RangeError] if +other+ is not a number or is not a real number
  # @raise [ZeroDivisionError] if +other+ is zero
  #
  # @since 0.2.1
  def fdiv(other)
    check_divisibility(other)

    other = other.real
    new { _1.fdiv(other) } # steep:ignore BlockBodyTypeMismatch
  end

  # Divide all coefficients by a real +other+,
  # converting results to integers using +#floor+.
  #
  # This is equal to +(self / other).floor+.
  #
  # @example
  #   VectorNumber[10].div(3) # => (3)
  #   VectorNumber["a"].div(2) # => (0)
  #   VectorNumber["a"].div(VectorNumber[2]) # => (0)
  #   VectorNumber[-10, "string"].div(100) # => (-1)
  #   # Can't divide by a non-real:
  #   VectorNumber["a"].div(VectorNumber["b"]) # RangeError
  # @example numeric types can be divided in reverse
  #   2.div(VectorNumber[10]) # => (0)
  #   # Can't divide by a non-real:
  #   2.div(VectorNumber["a"]) # RangeError
  #
  # @see #divmod
  # @see #%
  # @see #floor
  #
  # @param other [Numeric, VectorNumber]
  # @return [VectorNumber]
  # @raise [RangeError] if +other+ is not a number or is not a real number
  # @raise [ZeroDivisionError] if +other+ is zero
  #
  # @since 0.2.6
  def div(other)
    check_divisibility(other)

    other = other.real
    # @type var other: Float
    new { _1.div(other) }
  end

  # Divide all coefficients by a real +other+,
  # converting results to integers using +#ceil+.
  #
  # This is equal to +(self / other).ceil+.
  #
  # @example
  #   VectorNumber[10].ceildiv(3) # => (4)
  #   VectorNumber["a"].ceildiv(2) # => (1⋅"a")
  #   (VectorNumber["a"] - 3).ceildiv(2) # => (1⋅"a" - 1)
  #   VectorNumber[-10, "string"].ceildiv(100) # => (1⋅"string")
  #   # Can't divide by a non-real:
  #   VectorNumber["a"].ceildiv(VectorNumber["b"]) # RangeError
  #
  # @see #div
  # @see #ceil
  # @see Integer#ceildiv
  #
  # @param other [Numeric, VectorNumber]
  # @return [VectorNumber]
  # @raise [RangeError] if +other+ is not a number or is not a real number
  # @raise [ZeroDivisionError] if +other+ is zero
  #
  # @since <<next>>
  def ceildiv(other)
    check_divisibility(other)

    other = other.real
    other = Rational(other) if other.integer?
    # @type var other: Float
    new { (_1 / other).ceil }
  end

  # Return the modulus of dividing self by a real +other+ as a vector.
  #
  # This is equal to +self - other * (self/other).floor+,
  # or, alternatively, +self - other * self.div(other)+.
  #
  # @example
  #   VectorNumber[10] % 3 # => (1)
  #   VectorNumber["a", "b", 6].modulo(2) # => (1⋅"a" + 1⋅"b")
  #   -VectorNumber["a"] % VectorNumber[2] # => (1⋅"a")
  #   # Can't divide by a non-real:
  #   VectorNumber["a"] % VectorNumber["b"] # RangeError
  # @example numeric types can be divided in reverse
  #   3 % VectorNumber[10] # => (3)
  #   # Can't divide by a non-real:
  #   3 % VectorNumber["a"] # RangeError
  # @example compare to #remainder
  #   VectorNumber[-5] % 3 # => (1)
  #   VectorNumber[-5].remainder(3) # => (-2)
  #
  # @see #divmod
  # @see #div
  # @see #remainder
  # @see Numeric#%
  #
  # @param other [Numeric, VectorNumber]
  # @return [VectorNumber]
  # @raise [RangeError] if +other+ is not a number or is not a real number
  # @raise [ZeroDivisionError] if +other+ is zero
  #
  # @since 0.2.6
  def %(other)
    check_divisibility(other)

    other = other.real
    # @type var other: Float
    new { _1 % other }
  end

  # @since 0.2.6
  alias modulo %

  # Return the quotient and modulus of dividing self by a real +other+.
  # There is no performance benefit compared to calling {#div} and {#%} separately.
  #
  # @example
  #   VectorNumber[10].divmod(3) # => [(3), (1)]
  #   VectorNumber["a"].divmod(2) # => [(0), (1⋅"a")]
  #   VectorNumber["a"].divmod(VectorNumber[2]) # => [(0), (1⋅"a")]
  #   # Can't divide by a non-real:
  #   VectorNumber["a"].divmod(VectorNumber["b"]) # RangeError
  # @example numeric types can be divided in reverse
  #   3.divmod(VectorNumber[10]) # => [(0), (3)]
  #   # Can't divide by a non-real:
  #   3.divmod(VectorNumber["a"]) # RangeError
  #
  # @see #div
  # @see #%
  #
  # @param other [Numeric, VectorNumber]
  # @return [Array(VectorNumber, VectorNumber)]
  # @raise [RangeError] if +other+ is not a number or is not a real number
  # @raise [ZeroDivisionError] if +other+ is zero
  #
  # @since 0.2.6
  def divmod(other)
    [div(other), modulo(other)]
  end

  # Return the remainder of dividing self by a real +other+ as a vector.
  #
  # This is equal to +self - other * (self/other).truncate+.
  #
  # @example
  #   VectorNumber[10].remainder(3) # => (1)
  #   VectorNumber["a"].remainder(2) # => (1⋅"a")
  #   -VectorNumber["a"].remainder(VectorNumber[2]) # => (-1⋅"a")
  #   # Can't divide by a non-real:
  #   VectorNumber["a"].remainder(VectorNumber["b"]) # RangeError
  # @example numeric types can be divided in reverse
  #   3.remainder(VectorNumber[10]) # => (3)
  #   # Can't divide by a non-real:
  #   3.remainder(VectorNumber["a"]) # RangeError
  # @example compare to #%
  #   VectorNumber[-5] % 3 # => (1)
  #   VectorNumber[-5].remainder(3) # => (-2)
  #
  # @see #%
  # @see Numeric#remainder
  #
  # @param other [Numeric, VectorNumber]
  # @return [VectorNumber]
  # @raise [RangeError] if +other+ is not a number or is not a real number
  # @raise [ZeroDivisionError] if +other+ is zero
  #
  # @since 0.2.6
  def remainder(other)
    check_divisibility(other)

    other = other.real
    # @type var other: Float
    new { _1.remainder(other) }
  end

  private

  # @raise [RangeError] unless +other+ is a real number
  # @raise [ZeroDivisionError]
  def check_divisibility(other)
    unless real_number?(other)
      raise RangeError,
            "can't divide #{self} by #{Kernel.instance_method(:inspect).bind_call(other)}",
            caller
    end
    raise ZeroDivisionError, "divided by 0", caller if other.zero?
  end
end
