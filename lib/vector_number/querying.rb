# frozen_string_literal: true

class VectorNumber
  # Methods for querying state of the number.
  # Mostly modeled after {::Complex}.
  module Querying
    # Whether this VectorNumber can be considered strictly numeric, e.g. real or complex.
    #
    # @example
    #   VectorNumber[2].numeric? # => true
    #   VectorNumber[2, 3i].numeric? # => true
    #   VectorNumber[2, "a"].numeric? # => false
    #   VectorNumber[2, 3i].numeric?(1) # => false
    #
    # @param dimensions [Integer] number of dimensions to consider "numeric"
    #   - 0 — zero
    #   - 1 — real number
    #   - 2 — complex number, etc.
    # @return [Boolean]
    # @raise [ArgumentError] if +dimensions+ is negative
    #
    # @since 0.2.0
    def numeric?(dimensions = 2)
      raise ArgumentError, "`dimensions` must be non-negative" unless dimensions >= 0

      size <= dimensions && (1..dimensions).count { @data[UNIT[_1]].nonzero? } == size
    end

    # Whether this VectorNumber contains any non-numeric parts.
    #
    # @example
    #   VectorNumber[2].nonnumeric? # => false
    #   VectorNumber[2, 3i].nonnumeric? # => false
    #   VectorNumber[2, "a"].nonnumeric? # => true
    #   VectorNumber[2, 3i].nonnumeric?(1) # => true
    #
    # @param (see #numeric?)
    # @return (see #numeric?)
    # @raise (see #numeric?)
    #
    # @since 0.2.1
    def nonnumeric?(dimensions = 2) = !numeric?(dimensions)

    # Returns +true+ if all coefficients are finite, +false+ otherwise.
    #
    # @example
    #   VectorNumber[2].finite? # => true
    #   VectorNumber[Float::NAN].finite? # => false
    #   VectorNumber["a"].mult(Float::INFINITY).finite? # => false
    #
    # @return [Boolean]
    #
    # @since 0.1.0
    def finite?
      all? { |_u, v| v.finite? }
    end

    # Returns +1+ if any coefficients are infinite, +nil+ otherwise.
    #
    # This behavior is the same as +Complex+'s.
    #
    # @example
    #   VectorNumber[2].infinite? # => nil
    #   VectorNumber[Float::NAN].infinite? # => 1
    #   VectorNumber["a"].mult(-Float::INFINITY).infinite? # => 1
    #
    # @return [1, nil]
    #
    # @since 0.1.0
    def infinite?
      finite? ? nil : 1 # rubocop:disable Style/ReturnNilInPredicateMethodDefinition
    end

    # Returns +true+ if there are no non-zero coefficients, and +false+ otherwise.
    #
    # @example
    #   VectorNumber["c"].zero? # => false
    #   VectorNumber[].zero? # => true
    #
    # @return [Boolean]
    #
    # @since 0.1.0
    def zero? = size.zero?

    # Returns +self+ if there are any non-zero coefficients, +nil+ otherwise.
    #
    # This behavior is the same as +Numeric+'s.
    #
    # @example
    #   VectorNumber["ab", "cd"].nonzero? # => (1⋅'ab' + 1⋅'cd')
    #   VectorNumber[].nonzero? # => nil
    #
    # @return [VectorNumber, nil]
    #
    # @since 0.1.0
    def nonzero?
      zero? ? nil : self # rubocop:disable Style/ReturnNilInPredicateMethodDefinition
    end

    # Returns +true+ if number is non-zero and all non-zero coefficients are positive,
    # and +false+ otherwise.
    #
    # @example
    #   VectorNumber["a"].positive? # => true
    #   VectorNumber[2].neg.positive? # => false
    #   (VectorNumber["1"] - VectorNumber[1]).positive? # => false
    #   VectorNumber[0].positive? # => false
    #
    # @return [Boolean]
    #
    # @since 0.1.0
    def positive?
      !zero? && all? { |_u, c| c.positive? }
    end

    # Returns +true+ if number is non-zero and all non-zero coefficients are negative,
    # and +false+ otherwise.
    #
    # @example
    #   VectorNumber["a"].neg.negative? # => true
    #   VectorNumber[-2].neg.negative? # => false
    #   (VectorNumber["1"] - VectorNumber[1]).negative? # => false
    #   VectorNumber[0].negative? # => false
    #
    # @return [Boolean]
    #
    # @since 0.1.0
    def negative?
      !zero? && all? { |_u, c| c.negative? }
    end

    # Always returns +false+, as vectors are not real numbers.
    #
    # This behavior is the same as +Complex+'s.
    #
    # @see #numeric?
    #
    # @return [false]
    #
    # @since 0.1.0
    def real? = false

    # Always returns +false+, as vectors are not +Integer+s.
    #
    # @return [false]
    #
    # @since 0.2.1
    def integer? = false
  end
end
