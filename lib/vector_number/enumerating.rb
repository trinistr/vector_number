# frozen_string_literal: true

class VectorNumber < Numeric
  # Methods for enumerating values of the number.
  module Enumerating
    include Enumerable

    # Iterate through every pair of unit and coefficient.
    # Returns {::Enumerator} if no block is given.
    # @overload each
    #   @yieldparam unit [Object]
    #   @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
    #   @yieldreturn [void]
    #   @return [VectorNumber] self
    # @overload each
    #   @return [Enumerator]
    def each
      return to_enum { size } unless block_given?

      @data.each { |u, c| yield u, c if c.nonzero? }
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
  end
end
