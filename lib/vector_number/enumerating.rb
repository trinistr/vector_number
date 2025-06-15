# frozen_string_literal: true

class VectorNumber
  # Methods for enumerating values of the number.
  module Enumerating
    # @since 0.1.0
    include ::Enumerable

    # Iterate through every pair of unit and coefficient.
    # Returns {::Enumerator} if no block is given.
    #
    # @overload each
    #   @yieldparam unit [Object]
    #   @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
    #   @yieldreturn [void]
    #   @return [VectorNumber] self
    # @overload each
    #   @return [Enumerator]
    #
    # @since 0.1.0
    def each(&)
      return to_enum { size } unless block_given?

      @data.each(&)
      self
    end

    # @since 0.1.0
    alias each_pair each

    # Get a list of units with non-zero coefficients.
    #
    # @return [Array<Object>]
    #
    # @since 0.1.0
    def units
      @data.keys
    end

    # @since 0.1.0
    alias keys units

    # Get a list of non-zero coefficients.
    #
    # @return [Array<Integer, Float, Rational, BigDecimal>]
    #
    # @since 0.1.0
    def coefficients
      @data.values
    end

    # @since 0.1.0
    alias values coefficients

    # Get mutable hash with vector's data.
    #
    # Returned hash has a default value of 0.
    #
    # @return [Hash{Object => Integer, Float, Rational, BigDecimal}]
    #
    # @since 0.1.0
    def to_h(&)
      # TODO: Remove block argument.
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
    #
    # @since 0.2.4
    def [](unit)
      @data[unit] || 0
    end

    # Check if a unit has a non-zero coefficient.
    #
    # @param unit [Object]
    # @return [Boolean]
    #
    # @since 0.2.4
    def unit?(unit)
      @data.key?(unit)
    end

    # @since 0.2.4
    alias key? unit?
  end
end
