# frozen_string_literal: true

class VectorNumber
  # Methods for converting to different number classes.
  module Converting
    # Return real part of the number.
    #
    # @return [Integer, Float, Rational, BigDecimal]
    #
    # @since 0.1.0
    def real
      @data[R]
    end

    # Return imaginary part of the number.
    #
    # @return [Integer, Float, Rational, BigDecimal]
    #
    # @since 0.1.0
    def imaginary
      @data[I]
    end

    # @since 0.2.1
    alias imag imaginary

    # Return value as an Integer, truncating it, if only real part is non-zero.
    #
    # @return [Integer]
    # @raise [RangeError] if any non-real part is non-zero
    #
    # @since 0.1.0
    def to_i
      numeric?(1) ? real.to_i : raise_convert_error(Integer)
    end

    # @since 0.1.0
    alias to_int to_i

    # Return value as a Float if only real part is non-zero.
    #
    # @return [Float]
    # @raise [RangeError] if any non-real part is non-zero
    #
    # @since 0.1.0
    def to_f
      numeric?(1) ? real.to_f : raise_convert_error(Float)
    end

    # Return value as a Rational if only real part is non-zero.
    #
    # @return [Rational]
    # @raise [RangeError] if any non-real part is non-zero
    #
    # @since 0.1.0
    def to_r
      numeric?(1) ? real.to_r : raise_convert_error(Rational)
    end

    # Return value as a BigDecimal if only real part is non-zero.
    #
    # @param ndigits [Integer] precision
    # @return [BigDecimal]
    # @raise [RangeError] if any non-real part is non-zero
    # @raise [NameError] if BigDecimal is not defined
    #
    # @since 0.1.0
    def to_d(ndigits = nil)
      if numeric?(1)
        return BigDecimal(real, ndigits) if ndigits
        return BigDecimal(real, Float::DIG) if real.is_a?(Float)

        BigDecimal(real)
      else
        raise_convert_error(BigDecimal)
      end
    end

    # Return value as a Complex if only real and/or imaginary parts are non-zero.
    #
    # @return [Complex]
    # @raise [RangeError] if any non-real, non-imaginary part is non-zero
    #
    # @since 0.1.0
    def to_c
      numeric?(2) ? Complex(real, imaginary) : raise_convert_error(Complex)
    end

    private

    def raise_convert_error(klass)
      raise RangeError, "can't convert #{self} into #{klass}", caller
    end
  end
end
