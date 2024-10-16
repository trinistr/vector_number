# frozen_string_literal: true

class VectorNumber
  # Methods for enumerating values of the number.
  module Enumerating
    include ::Enumerable

    # Iterate through every pair of unit and coefficient.
    # Returns {::Enumerator} if no block is given.
    # @overload each
    #   @yieldparam unit [Object]
    #   @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
    #   @yieldreturn [void]
    #   @return [VectorNumber] self
    # @overload each
    #   @return [Enumerator]
    def each(&)
      return to_enum { size } unless block_given?

      @data.each(&)
      self
    end

    alias each_pair each

    # @return [Array<Object>]
    def units
      @data.keys
    end

    alias keys units

    # @return [Array<Integer, Float, Rational, BigDecimal>]
    def coefficients
      @data.values
    end

    alias values coefficients

    # @return [Hash{Object => Integer, Float, Rational, BigDecimal}]
    def to_h(&)
      if block_given?
        @data.to_h(&)
      else
        @data.dup
      end
    end

    # Get the coefficient for the unit.
    #
    # If the +unit?(unit)+ is false, 0 is returned.
    # Note that units for real and imaginary parts are
    # VectorNumber::R and VectorNumber::I respectively.
    #
    # @param unit [Object]
    # @return [Integer, Float, Rational, BigDecimal]
    def [](unit)
      @data[unit] || 0
    end

    # Check if a unit has a non-zero coefficient.
    #
    # @param unit [Object]
    # @return [Boolean]
    def unit?(unit)
      @data.key?(unit)
    end

    alias key? unit?
  end
end
