# frozen_string_literal: true

class VectorNumber
  ### Methods for converting to different number classes.

  # Return real part of the number.
  #
  # @example
  #   VectorNumber[23, "a"].real # => 23
  #   VectorNumber["a"].real # => 0
  #
  # @return [Integer, Float, Rational, BigDecimal]
  #
  # @since 0.1.0
  def real = @data[R]

  # Return imaginary part of the number.
  #
  # @example
  #   VectorNumber[23, "a"].imaginary # => 0
  #   VectorNumber["a", Complex(1, 2r)].imag # => (2/1)
  #
  # @return [Integer, Float, Rational, BigDecimal]
  #
  # @since 0.1.0
  def imaginary = @data[I]

  # @since 0.2.1
  alias imag imaginary

  # Return value as an Integer, truncating it, if only real part is non-zero.
  #
  # @example
  #   VectorNumber[13.5].to_i # => 13
  #   VectorNumber[13r/12].to_int # => 1
  #   [1.1, 2.2, 3.3][VectorNumber[2]] # => 3.3
  #   VectorNumber[2, 2i].to_i # RangeError
  #   VectorNumber[2, :i].to_f # RangeError
  #
  #   Integer(VectorNumber[2]) # => 2
  #   Integer(VectorNumber[2, "i"]) # RangeError
  #
  # @return [Integer]
  # @raise [RangeError] if any non-real part is non-zero
  #
  # @since 0.1.0
  def to_i
    raise_convert_error(Integer) unless numeric?(1)

    real.to_i
  end

  # @since 0.1.0
  alias to_int to_i

  # Return value as a Float if only real part is non-zero.
  #
  # @example
  #   VectorNumber[13.5].to_f # => 13.5
  #   VectorNumber[13r/12].to_f # => 1.0833333333333333
  #   VectorNumber[2, 2i].to_f # RangeError
  #   VectorNumber[2, :i].to_f # RangeError
  #
  #   Float(VectorNumber[2]) # => 2.0
  #   Float(VectorNumber[2, "i"]) # RangeError
  #
  # @return [Float]
  # @raise [RangeError] if any non-real part is non-zero
  #
  # @since 0.1.0
  def to_f
    raise_convert_error(Float) unless numeric?(1)

    real.to_f
  end

  # Return value as a Rational if only real part is non-zero.
  #
  # @example
  #   VectorNumber[13.5].to_r # => (27/2)
  #   VectorNumber[13r/12].to_r # => (13/12)
  #   VectorNumber[2, 2i].to_r # RangeError
  #   VectorNumber[2, :i].to_r # RangeError
  #
  #   Rational(VectorNumber[2]) # => (2/1)
  #   Rational(VectorNumber[2, "i"]) # RangeError
  #
  # @return [Rational]
  # @raise [RangeError] if any non-real part is non-zero
  #
  # @since 0.1.0
  def to_r
    raise_convert_error(Rational) unless numeric?(1)

    real.to_r
  end

  # Return value as a BigDecimal if only real part is non-zero.
  #
  # @example
  #   VectorNumber[13.5].to_d # => 0.135e2
  #   VectorNumber[13r/12].to_d # ArgumentError
  #   VectorNumber[13r/12].to_d(5) # => 0.10833e1
  #   VectorNumber[2, 2i].to_d # RangeError
  #   VectorNumber[2, :i].to_d # RangeError
  #
  #   # This does't work without NumericRefinements:
  #   BigDecimal(VectorNumber[2]) # TypeError
  #   # #to_s can be used as a workaround if refinements aren't used:
  #   BigDecimal(VectorNumber[2].to_s) # => 0.2e1
  #   BigDecimal(VectorNumber[2, "i"].to_s) # => ArgumentError
  #
  # @param ndigits [Integer] precision
  # @return [BigDecimal]
  # @raise [RangeError] if any non-real part is non-zero
  # @raise [NameError] if BigDecimal is not defined
  #
  # @see Kernel.BigDecimal
  # @see NumericRefinements
  #
  # @since 0.1.0
  def to_d(ndigits = nil)
    raise_convert_error(BigDecimal) unless numeric?(1)

    return BigDecimal(real, ndigits) if ndigits
    return BigDecimal(real, Float::DIG) if real.is_a?(Float)

    BigDecimal(real)
  end

  # Return value as a Complex if only real and/or imaginary parts are non-zero.
  #
  # @example
  #   VectorNumber[13.5].to_c # => (13.5+0i)
  #   VectorNumber[13r/12].to_c # => ((13/12)+0i)
  #   VectorNumber[2, 2i].to_c # => (2+2i)
  #   VectorNumber[2, :i].to_c # RangeError
  #
  #   Complex(VectorNumber[2]) # => (2+0i)
  #   Complex(VectorNumber[2, "i"]) # RangeError
  #
  # @return [Complex]
  # @raise [RangeError] if any non-real, non-imaginary part is non-zero
  #
  # @since 0.1.0
  def to_c
    raise_convert_error(Complex) unless numeric?(2)

    Complex(real, imaginary)
  end

  private

  def raise_convert_error(klass)
    raise RangeError, "can't convert #{self} into #{klass}", caller
  end
end
