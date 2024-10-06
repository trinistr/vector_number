# frozen_string_literal: true

class VectorNumber
  # Refinements of Numeric classes to better work with VectorNumber and similar classes.
  module NumericRefinements
    # Refinement module to provide a +#<=>+ method that can work backwards.
    # @note Currently only applies to Complex on *3.1*,
    #   as other numeric classes rely on +#coerce+.
    module CommutativeShuttle
      # Commutative +#<=>+.
      # @example without refinements
      #   Complex(1, 0) <=> VectorNumber[2] # => nil
      #   VectorNumber[2] <=> Complex(1, 0) # => 1
      # @example with refinements
      #   require "vector_number/numeric_refinements"
      #   using VectorNumber::NumericRefinements
      #   Complex(1, 0) <=> VectorNumber[2] # => -1
      #   VectorNumber[2] <=> Complex(1, 0) # => 1
      def <=>(other)
        comparison = super
        return comparison if comparison || !other.respond_to?(:<=>)

        comparison = other <=> self
        -comparison if comparison
      end
    end

    if (Complex(1, 0) <=> VectorNumber[1]).nil?
      refine(Complex) { import_methods CommutativeShuttle }
    end

    # Refinement module to change Kernel#BigDecimal so it works with +#to_d+.
    # @note `BigDecimal` needs to be defined for this refinement to activate.
    module BigDecimalToD
      # BigDecimal() that first tries to use #to_d.
      # @param value [Object]
      # @param exception [Boolean]
      # @overload BigDecimal(value, exception: true)
      # @overload BigDecimal(value, ndigits, exception: true)
      #   @param ndigits [Integer]
      # @return [BigDecimal, nil]
      # @raise [TypeError]
      def BigDecimal(value, ndigits = nil, exception: true) # rubocop:disable Naming/MethodName
        if value.respond_to?(:to_d)
          ndigits.nil? ? value.to_d : value.to_d(ndigits)
        else
          super
        end
      end
    end

    refine(Kernel) { import_methods BigDecimalToD } if defined?(BigDecimal)
  end
end
