# frozen_string_literal: true

class VectorNumber
  # Various mathematical operations that are also conversions.
  module MathConverting
    # Return the absolute value of a vector, i.e. its length.
    # @return [Float]
    def abs
      Math.sqrt(coefficients.reduce(0.0) { |result, coefficient| result + coefficient.abs2 })
    end

    alias magnitude abs

    # Return the square of absolute value.
    # @return [Float]
    def abs2 # rubocop:disable Naming/VariableNumber
      abs**2
    end

    # Return a new vector with every coefficient truncated using their +#truncate+.
    # @param digits [Integer]
    # @return [VectorNumber]
    def truncate(digits = 0)
      new { _1.truncate(digits) }
    end

    # Return a new vector with every coefficient rounded using their +#ceil+.
    # @param digits [Integer]
    # @return [VectorNumber]
    def ceil(digits = 0)
      new { _1.ceil(digits) }
    end

    # Return a new vector with every coefficient rounded using their +#floor+.
    # @param digits [Integer]
    # @return [VectorNumber]
    def floor(digits = 0)
      new { _1.floor(digits) }
    end

    # Return a new vector with every coefficient rounded using their +#round+.
    # @param digits [Integer]
    # @param half [Symbol, nil] one of +:up+, +:down+ or +:even+, see +Float#round+ for meaning
    # @return [VectorNumber]
    def round(digits = 0, half: :up)
      bd_mode =
        case half
        when :down then :half_down
        when :even then :half_even
        else :half_up
        end
      new do |coefficient|
        if defined?(BigDecimal) && coefficient.is_a?(BigDecimal)
          coefficient.round(digits, bd_mode)
        else
          coefficient.round(digits, half:)
        end
      end
    end
  end
end
