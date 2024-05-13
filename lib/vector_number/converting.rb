# frozen_string_literal: true

class VectorNumber
  # Methods for converting to different number classes.
  module Converting
    # Return real part of the number.
    # @return [Integer, Float, Rational, BigDecimal]
    def real
      @data[1]
    end

    # Return imaginary part of the number.
    # @return [Integer, Float, Rational, BigDecimal]
    def imaginary
      @data[I]
    end

    # Return value as an Integer, truncating it, if only real part is non-zero.
    # @return [Integer]
    # @raise [RangeError] if any non-real part is non-zero
    def to_i
      convertible_to_real? ? real.to_i : raise_convert_error(Integer)
    end

    alias to_int to_i

    # Return value as a Float if only real part is non-zero.
    # @return [Float]
    # @raise [RangeError] if any non-real part is non-zero
    def to_f
      convertible_to_real? ? real.to_f : raise_convert_error(Float)
    end

    # Return value as a Rational if only real part is non-zero.
    # @return [Rational]
    # @raise [RangeError] if any non-real part is non-zero
    def to_r
      convertible_to_real? ? real.to_r : raise_convert_error(Rational)
    end

    # Return value as a BigDecimal if only real part is non-zero.
    # @return [BigDecimal]
    # @raise [RangeError] if any non-real part is non-zero
    # @raise [NoMethodError] if 'bigdecimal/util' was not required
    def to_d
      convertible_to_real? ? real.to_d : raise_convert_error(BigDecimal)
    end

    # Return value as a Complex if only real and/or imaginary parts are non-zero.
    # @return [Complex]
    # @raise [RangeError] if any non-real, non-imaginary part is non-zero
    def to_c
      convertible_to_complex? ? Complex(real, imaginary) : raise_convert_error(Complex)
    end

    private

    def convertible_to_real?
      size.zero? || (size == 1 && real.nonzero?)
    end

    def convertible_to_complex?
      convertible_to_real? || (size == 1 && imaginary.nonzero?) || (size == 2 && real.nonzero? && imaginary.nonzero?)
    end

    def raise_convert_error(klass)
      raise RangeError, "can't convert #{self} into #{klass}", caller
    end
  end
end
