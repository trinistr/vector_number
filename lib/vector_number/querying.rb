# frozen_string_literal: true

class VectorNumber
  # Methods for querying state of the number.
  # Mostly modeled after {::Complex}.
  module Querying
    # Whether this VectorNumber can be considered strictly numeric, e.g. real or complex.
    # @param dimensions [Integer] number of dimensions to consider "numeric"
    #   - 0 — zero
    #   - 1 — real number
    #   - 2 — complex number, etc.
    # @return [Boolean]
    # @raise [ArgumentError] if +dimensions+ is negative
    def numeric?(dimensions = 2)
      raise ArgumentError, "`dimensions` must be non-negative" unless dimensions >= 0

      size <= dimensions && (1..dimensions).count { @data[UNIT[_1]].nonzero? } == size
    end

    # Whether this VectorNumber contains any non-numeric parts.
    # @param (see #numeric?)
    # @return (see #numeric?)
    # @raise (see #numeric?)
    def nonnumeric?(dimensions = 2)
      raise ArgumentError, "`dimensions` must be non-negative" unless dimensions >= 0

      !numeric?(dimensions)
    end

    # Returns +true+ if all coefficients are finite, +false+ otherwise.
    # @return [Boolean]
    def finite?
      all? { |_u, v| v.finite? }
    end

    # Returns +1+ if any coefficients are infinite, +nil+ otherwise.
    # @return [1, nil]
    def infinite?
      finite? ? nil : 1
    end

    # Returns +true+ if there are no non-zero coefficients, +false+ otherwise.
    # @return [Boolean]
    def zero?
      size.zero?
    end

    # Returns +self+ if there are any non-zero coefficients, +nil+ otherwise.
    # @return [VectorNumber, nil]
    def nonzero?
      zero? ? nil : self
    end

    # Returns +true+ if all non-zero coefficients are positive,
    # +false+ if all non-zero coefficients are negative or all are zero,
    # or +nil+ otherwise.
    # @return [Boolean, nil]
    def positive?
      # REVIEW: elsif branch is slow because it needs decide on false/nil.
      #   We could just return false and be done with it.
      #   User then could test both `postitive?` and `negative?` if they want.
      if nonzero? && all? { |_u, c| c.positive? }
        true
      elsif zero? || all? { |_u, c| c.negative? }
        false
      end
    end

    # Returns +true+ if all non-zero coefficients are negative,
    # +false+ if all non-zero coefficients are positive or all are zero,
    # or +nil+ otherwise.
    # @return [Boolean, nil]
    def negative?
      if nonzero? && all? { |_u, c| c.negative? }
        true
      elsif zero? || all? { |_u, c| c.positive? }
        false
      end
    end

    # Always returns +false+.
    # @return [false]
    def real?
      false
    end

    # Always returns +false+.
    # @return [false]
    def integer?
      false
    end
  end
end
