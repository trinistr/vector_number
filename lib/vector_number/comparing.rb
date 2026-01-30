# frozen_string_literal: true

class VectorNumber
  # @group Comparing

  # +Comparable+ is included for parity with +Numeric+.
  # @example using Comparable methods
  #   VectorNumber[12] < 0 # => false
  #   VectorNumber[12, "a"] < 0 # ArgumentError
  #   (VectorNumber[12]..VectorNumber[15]).include?(13) # => true
  #
  # @since 0.2.0
  include ::Comparable

  # Test whether +other+ has the same value with +==+ semantics.
  #
  # Values are considered equal if
  # - +other+ is a VectorNumber and it has the same units and equal coefficients, or
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
    return true if equal?(other)

    case other
    when VectorNumber
      size == other.size && @data == other.to_h
    when Numeric
      numeric?(2) && other.real == real && other.imaginary == imaginary
    else
      # Can't compare a number-like value to a non-number.
      false
    end
  end

  # Test whether +other+ is VectorNumber and has the same value with +eql?+ semantics.
  #
  # Values are considered equal only if +other+ is a VectorNumber
  # and it has exactly the same units and coefficients, though possibly in a different order.
  # Additionally, `a.eql?(b)` implies `a.hash == b.hash`.
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
  def eql?(other)
    return true if equal?(other)
    return false unless other.is_a?(VectorNumber)

    size.eql?(other.size) && @data.eql?(other.to_h)
  end

  # Generate an Integer hash value for self.
  #
  # Hash values are stable during runtime, but not between processes.
  #
  # @example
  #   VectorNumber["b", "a"].hash # => 3081872088394655324
  #   VectorNumber["a", "b"].hash # => 3081872088394655324
  #   VectorNumber["b", "c"].hash # => -1002381358514682371
  #
  # @return [Integer]
  #
  # @since 0.4.2
  def hash
    [self.class, @data].hash
  end

  # Compare to +other+ and return -1, 0, or 1
  # if +self+ is less than, equal, or larger than +other+ on real number line,
  # or +nil+ if any or both values are non-real.
  #
  # Most VectorNumbers are non-real and therefore not comparable with this method.
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
  # @see #numeric?
  # @see Comparable
  # @see NumericRefinements
  #
  # @param other [Object]
  # @return [Integer]
  # @return [nil] if +self+ or +other+ isn't a real number.
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
