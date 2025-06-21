# frozen_string_literal: true

class VectorNumber
  # Various mathematical operations that are also conversions.
  module MathConverting
    # Calculate the absolute value of the vector, i.e. its length.
    #
    # @example
    #   VectorNumber[5.3].abs # => 5.3
    #   VectorNumber[-5.3i].magnitude # => 5.3
    #   VectorNumber[-5.3i, "i"].abs # => 5.3935146240647205
    #
    # @return [Float]
    #
    # @since 0.2.2
    def abs
      Math.sqrt(abs2)
    end

    alias magnitude abs

    # Calculate the square of absolute value.
    #
    # @example
    #   VectorNumber[5.3].abs2 # => 5.3
    #   VectorNumber[-5.3i].abs2 # => 5.3
    #   VectorNumber[-5.3i, "i"].abs2 # => 29.09
    #
    # @return [Float]
    #
    # @since 0.2.2
    def abs2
      coefficients.sum(&:abs2)
    end

    # Return a new vector with every coefficient truncated using their +#truncate+.
    #
    # @example
    #   VectorNumber[5.39].truncate # => (5)
    #   VectorNumber[-5.35i].truncate # => (-5i)
    #   VectorNumber[-5.35i, "i"].truncate # => (-5i + 1⋅'i')
    #   VectorNumber[-5.35i, "i"].truncate(1) # => (-5.3i + 1⋅'i')
    #   VectorNumber[-5.35i, "i"].truncate(-1) # => (0)
    #
    # @param digits [Integer]
    # @return [VectorNumber]
    #
    # @since 0.2.1
    def truncate(digits = 0)
      new { _1.truncate(digits) }
    end

    # Return a new vector with every coefficient rounded using their +#ceil+.
    #
    # @example
    #   VectorNumber[5.39].ceil # => (6)
    #   VectorNumber[-5.35i].ceil # => (-5i)
    #   VectorNumber[-5.35i, "i"].ceil # => (-5i + 1⋅'i')
    #   VectorNumber[-5.35i, "i"].ceil(1) # => (-5.3i + 1⋅'i')
    #   VectorNumber[-5.35i, "i"].ceil(-1) # => (10⋅'i')
    #
    # @param digits [Integer]
    # @return [VectorNumber]
    #
    # @since 0.2.2
    def ceil(digits = 0)
      new { _1.ceil(digits) }
    end

    # Return a new vector with every coefficient rounded using their +#floor+.
    #
    # @example
    #   VectorNumber[5.39].floor # => (5)
    #   VectorNumber[-5.35i].floor # => (-6i)
    #   VectorNumber[-5.35i, "i"].floor # => (-6i + 1⋅'i')
    #   VectorNumber[-5.35i, "i"].floor(1) # => (-5.4i + 1⋅'i')
    #   VectorNumber[-5.35i, "i"].floor(-1) # => (-10i)
    #
    # @param digits [Integer]
    # @return [VectorNumber]
    #
    # @since 0.2.2
    def floor(digits = 0)
      new { _1.floor(digits) }
    end

    # Return a new vector with every coefficient rounded using their +#round+.
    #
    # @example
    #   VectorNumber[-4.5i, "i"].round(half: :up) # => (-5i + 1⋅'i')
    #   VectorNumber[-4.5i, "i"].round(half: :even) # => (-4i + 1⋅'i')
    #   VectorNumber[-5.5i, "i"].round(half: :even) # => (-6i + 1⋅'i')
    #   VectorNumber[-5.5i, "i"].round(half: :down) # => (-5i + 1⋅'i')
    #   VectorNumber[-5.35i, "i"].round(1) # => (-5.4i + 1⋅'i')
    #   VectorNumber[-5.35i, "i"].round(-1) # => (-10i)
    #
    # @param digits [Integer]
    # @param half [Symbol, nil] one of +:up+, +:down+ or +:even+,
    #   see +Float#round+ for meaning
    # @return [VectorNumber]
    #
    # @see Float#round
    #
    # @since 0.2.2
    def round(digits = 0, half: :up)
      if defined?(BigDecimal)
        bd_mode =
          case half
          when :down then :half_down
          when :even then :half_even
          else :half_up
          end
        new { _1.is_a?(BigDecimal) ? _1.round(digits, bd_mode) : _1.round(digits, half:) }
      else
        new { _1.round(digits, half:) }
      end
    end
  end
end
