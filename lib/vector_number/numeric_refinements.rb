# frozen_string_literal: true

class VectorNumber
  # Refinements of Numeric classes and Kernel to better work with VectorNumber and similar classes.
  #
  # These do not depend on {VectorNumber} and can technically be used separately.
  # Currently includes:
  # - refinement for +Complex#<=>+ to work with classes implementing +<=>+;
  # - refinement for +Kernel#BigDecimal+ to work with classes implementing +to_d+.
  #
  # @note Refinements won't work on Ruby 3.0.
  #
  # @example activating refinements
  #   require "vector_number/numeric_refinements"
  #   using VectorNumber::NumericRefinements
  #
  # @since 0.2.0
  module NumericRefinements
    # CommutativeShuttle refinement works only on 3.1, so it almost never actually runs.
    # There are tests for the correct behavior, however, so it's fine.
    # :nocov:

    # Refinement module to provide a +#<=>+ method that can work backwards.
    #
    # @note Currently only applies to Complex on *3.1*,
    #   as other numeric classes rely on +#coerce+.
    # @example without refinements
    #   VectorNumber[2] <=> Complex(1, 0) # => 1
    #   Complex(1, 0) <=> VectorNumber[2] # => nil
    # @example with refinements
    #   require "vector_number/numeric_refinements"
    #   using VectorNumber::NumericRefinements
    #   VectorNumber[2] <=> Complex(1, 0) # => 1
    #   Complex(1, 0) <=> VectorNumber[2] # => -1
    #
    # @since 0.2.1
    module CommutativeShuttle
      # Commutative +#<=>+.
      # Tries to call +other <=> self+ if +self <=> other+ returns +nil+.
      def <=>(other)
        comparison = super
        return comparison if comparison || !other.respond_to?(:<=>)

        comparison = other <=> self
        -comparison if comparison
      end
    end

    if (Complex(1, 0) <=> VectorNumber[1]).nil?
      refine(Complex) do
        import_methods CommutativeShuttle
      rescue
        warn "Numeric refinements are not available on Ruby < 3.1"
      end
    end
    # :nocov:

    # Refinement module to change Kernel#BigDecimal so it works with +#to_d+.
    #
    # @note `BigDecimal` needs to be defined for this refinement to activate.
    # @example without refinements
    #   BigDecimal(VectorNumber[2]) # can't convert VectorNumber into BigDecimal (TypeError)
    # @example with refinements
    #   require "vector_number/numeric_refinements"
    #   using VectorNumber::NumericRefinements
    #   BigDecimal(VectorNumber[2]) # => 0.2e1
    #
    # @since 0.2.1
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
          ndigits.nil? ? super(value, exception: exception) : super
        end
      end
    end

    # :nocov:
    if defined?(BigDecimal)
      refine(Kernel) do
        import_methods BigDecimalToD
      rescue
        warn "Numeric refinements are not available on Ruby < 3.1"
      end
    end
    # :nocov:
  end
end
