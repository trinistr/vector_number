# frozen_string_literal: true

class VectorNumber
  # Methods for querying state of the number.
  # Mostly modeled after {::Complex}.
  module Querying
    # Always returns +false+.
    # @return [false]
    def real?
      false
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
  end
end
