# frozen_string_literal: true

class VectorNumber
  # Methods for querying state of the number.
  # Mostly modeled after {::Complex}.
  module Querying
    # Whether this VectorNumber can be considered strictly numeric, e.g. real or complex.
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
    # @param (see #numeric?)
    # @return (see #numeric?)
    # @raise (see #numeric?)
    #
    # @since 0.2.1
    def nonnumeric?(dimensions = 2)
      raise ArgumentError, "`dimensions` must be non-negative" unless dimensions >= 0

      !numeric?(dimensions)
    end

    # Returns +true+ if all coefficients are finite, +false+ otherwise.
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
    # @return [1, nil]
    #
    # @since 0.1.0
    def infinite?
      finite? ? nil : 1 # rubocop:disable Style/ReturnNilInPredicateMethodDefinition
    end

    # Returns +true+ if there are no non-zero coefficients, and +false+ otherwise.
    #
    # @return [Boolean]
    #
    # @since 0.1.0
    def zero?
      size.zero?
    end

    # Returns +self+ if there are any non-zero coefficients, +nil+ otherwise.
    #
    # This behavior is the same as +Numeric+'s.
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
    # @return [Boolean]
    #
    # @since 0.1.0
    def positive?
      !zero? && all? { |_u, c| c.positive? }
    end

    # Returns +true+ if number is non-zero and all non-zero coefficients are negative,
    # and +false+ otherwise.
    #
    # @return [Boolean]
    #
    # @since 0.1.0
    def negative?
      !zero? && all? { |_u, c| c.negative? }
    end

    # Always returns +false+, as vectors are never real numbers.
    #
    # @see #numeric?
    #
    # @return [false]
    #
    # @since 0.1.0
    def real?
      false
    end

    # Always returns +false+, as vectors are not +Integer+s.
    #
    # @return [false]
    #
    # @since 0.2.1
    def integer?
      false
    end
  end
end
