# frozen_string_literal: true

class VectorNumber < Numeric
  # Methods for querying state of the number.
  # Mostly modeled after {Complex}.
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

    # Returns +true+ if all non-zero coefficients are positive,
    # +false+ if all non-zero coefficients are negative or all are zero,
    # or +nil+ otherwise.
    # @return [Boolean, nil]
    def positive?
      if nonzero? && all? { |_u, v| v.positive? }
        true
      elsif zero? || all? { |_u, v| v.negative? }
        false
      end
    end

    def negative?
      if nonzero? && all? { |_u, v| v.negative? }
        true
      elsif zero? || all? { |_u, v| v.positive? }
        false
      end
    end
  end
end
