# frozen_string_literal: true

class VectorNumber
  # Refinements of Numeric classes to better work with VectorNumber and similar classes.
  # @note This file must be required after "bigdecimal" to refine {BigDecimal}.
  module NumericRefinements
    # Associative +<=>+.
    # @example without refinements
    #   1 <=> VectorNumber[2] # => nil
    #   VectorNumber[2] <=> 1 # => 1
    # @example with refinements
    #   require "vector_number/numeric_refinements"
    #   using VectorNumber::NumericRefinements
    #   1 <=> VectorNumber[2] # => -1
    #   VectorNumber[2] <=> 1 # => 1
    def <=>(other)
      super || (other <=> self if other.respond_to?(:<=>))
    end

    [Numeric, Integer, Float, Rational, Complex].each do |klass|
      refine klass do
        import_methods NumericRefinements
      end
    end

    if defined?(BigDecimal)
      refine BigDecimal do
        import_methods NumericRefinements
      end
    end
  end
end
