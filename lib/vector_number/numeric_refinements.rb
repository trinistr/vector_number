# frozen_string_literal: true

class VectorNumber
  # Refinements of Numeric classes to better work with VectorNumber and similar classes.
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
    # @note Currently only applies to Complex, as other numeric classes rely on +#coerce+.
    def <=>(other)
      super || (other <=> self if other.respond_to?(:<=>))
    end

    [Complex].each { |klass| refine(klass) { import_methods NumericRefinements } }
  end
end
