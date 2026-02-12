# frozen_string_literal: true

class VectorNumber
  # @group Hash-like operations

  # +Enumerable+ is included so its methods can be used.
  # @example using Enumerable methods
  #   VectorNumber["a", "b", 6].include?(["a", 1]) # => true
  #   VectorNumber["a", "b", 6].select { |u, c| u.is_a?(String) } # => [["a", 1], ["b", 1]]
  include ::Enumerable

  # Iterate through every pair of unit and coefficient.
  # Returns +Enumerator+ (with set +size+) if no block is given.
  #
  # @example
  #   v = VectorNumber["a", "b", 6]
  #   units = []
  #   v.each { |u, c| units << u unless VectorNumber.numeric_unit?(u) } # => (1⋅"a" + 1⋅"b" + 6)
  #   units # => ["a", "b"]
  # @example Enumerator
  #   v.each.size # => 3
  #   (v.each + [["d", 0]]).map(&:first) # => ["a", "b", unit/1, "d"]
  #   v.each_pair.peek # => ["a", 1]
  #
  # @overload each
  #   @yieldparam unit [Object]
  #   @yieldparam coefficient [Numeric]
  #   @yieldreturn [void]
  #   @return [VectorNumber] self
  # @overload each
  #   @return [Enumerator]
  #
  # @see Enumerable
  # @see Enumerator
  def each(&block)
    return to_enum { size } unless block_given?

    # @type var block: ^([unit_type, coefficient_type]) -> untyped
    @data.each(&block)
    self
  end

  alias each_pair each

  # Get a list of units with non-zero coefficients.
  #
  # @example
  #   VectorNumber["a", "b", 6].units # => ["a", "b", unit/1]
  #   VectorNumber.new.keys # => []
  #
  # @return [Array<Object>]
  def units = @data.keys

  alias keys units

  # Get a list of non-zero coefficients.
  #
  # @example
  #   VectorNumber["a", "b", 6].coefficients # => [1, 1, 6]
  #   VectorNumber.new.values # => []
  #
  # @return [Array<Numeric>]
  def coefficients = @data.values

  alias values coefficients

  # Get a list of coefficients corresponding to +units+.
  #
  # @example
  #   VectorNumber["a", "b", 6].coefficients_at("a", "b") # => [1, 1]
  #   VectorNumber["a", "b", 6].coefficients_at("a", "c") # => [1, 0]
  #   VectorNumber["a", "b", 6].coefficients_at("c", "b", "c") # => [0, 1, 0]
  #   VectorNumber["a", "b", 6].coefficients_at) # => []
  #
  # @see #fetch_coefficients
  #
  # @param units [Array<Object>]
  # @return [Array<Numeric>]
  #
  # @since <<next>>
  def coefficients_at(*units)
    @data.values_at(*units) # : Array[coefficient_type]
  end

  # @since <<next>>
  alias values_at coefficients_at

  # Get mutable hash with vector's data.
  #
  # Returned hash has a default value of 0.
  #
  # @example
  #   VectorNumber["a", "b", 6, 1i].to_h # => {"a" => 1, "b" => 1, unit/1 => 6, unit/i => 1}
  #   VectorNumber["a", "b", 6, 1i].to_h["c"] # => 0
  #
  # @return [Hash{Object => Numeric}]
  def to_h(&block)
    # TODO: Remove block argument.
    if block_given?
      # @type var block: ^(unit_type, coefficient_type) -> each_value_type
      @data.to_h(&block)
    else
      @data.dup
    end
  end

  # Get the coefficient for the unit.
  #
  # If the +unit?(unit)+ is false, 0 is returned.
  # Note that units for real and imaginary parts are
  # VectorNumber::R and VectorNumber::I respectively.
  #
  # @example
  #   VectorNumber["a", "b", 6]["a"] # => 1
  #   VectorNumber["a", "b", 6][VectorNumber::R] # => 6
  #   VectorNumber["a", "b", 6]["c"] # => 0
  #
  # @see #assoc
  # @see #fetch
  #
  # @param unit [Object]
  # @return [Numeric]
  #
  # @since 0.2.4
  def [](unit)
    @data[unit]
  end

  # Get a 2-element array containing a given unit and associated coefficient.
  #
  # @example
  #   VectorNumber["a", "b", 6].assoc("a") # => ["a", 1]
  #   VectorNumber["a", "b", 6].assoc(VectorNumber::R) # => [unit/1, 6]
  #   VectorNumber["a", "b", 6].assoc("c") # => ["c", 0]
  #
  # @see #[]
  #
  # @param unit [Object]
  # @return [Array(Object, Numeric)]
  #
  # @since <<next>>
  def assoc(unit)
    @data.assoc(unit) || [unit, 0]
  end

  # Finds and returns the object in nested objects that is specified by +identifiers+.
  #
  # As nested objects for a +VectorNumber+ are numeric coefficients,
  # digging deeper will most probably result in an error.
  #
  # @example
  #   VectorNumber["a", "b", 6].dig("a") # => 1
  #   VectorNumber["a", "b", 6].dig("c") # => 0
  #   VectorNumber["a", "b", 6].dig("a", 1) # TypeError
  #   { 1 => VectorNumber["a", "b", 6] }.dig(1, "a") # => 1
  #
  # @since <<next>>
  def dig(*identifiers)
    @data.dig(*identifiers)
  end

  # Get the coefficient for the unit, treating 0 coefficients as missing.
  #
  # If +self.unit?(unit)+ is +true+, returns the associated coefficient.
  # Otherwise:
  # - if neither block, not +default_value+ is given, raises +KeyError+;
  # - if block is given, returns the result of the block;
  # - if +default_value+ is given, returns +default_value+.
  #
  # @example
  #   VectorNumber["a", "b", 6].fetch("a") # => 1
  #   VectorNumber["a", "b", 6].fetch("c") # KeyError
  #   VectorNumber["a", "b", 6].fetch("c", "default") # => "default"
  #   VectorNumber["a", "b", 6].fetch("c") { |u| "default #{u}" } # => "default c"
  #
  # @see #[]
  # @see #fetch_coefficients
  # @see #unit?
  #
  # @overload fetch(unit)
  #   @param unit [Object]
  #   @return [Numeric]
  # @overload fetch(unit, default_value)
  #   @param unit [Object]
  #   @param default_value [Any]
  #   @return [Any]
  # @overload fetch(unit) { |unit| ... }
  #   @param unit [Object]
  #   @yieldparam unit [Object]
  #   @yieldreturn [Any]
  #   @return [Any]
  # @raise [KeyError] if default value was needed, but not provided
  #
  # @since <<next>>
  def fetch(...)
    @data.fetch(...) # steep:ignore UnresolvedOverloading
  end

  # Get coefficients for multiple units in the same way as {#fetch}.
  #
  # @example
  #   VectorNumber["a", "b", 6].fetch_coefficients(VectorNumber::R, "a") # => [6, 1]
  #   VectorNumber["a", "b", 6].fetch_coefficients("a", "c") # KeyError
  #   VectorNumber["a", "b", 6].fetch_coefficients("a", "c") { 0 } # => [1, 0]
  #   VectorNumber["a", "b", 6].fetch_coefficients("a", "a", "a") # => [1, 1, 1]
  #   VectorNumber["a", "b", 6].fetch_coefficients # => []
  #
  # @see #coefficients_at
  # @see #fetch
  # @see #unit?
  #
  # @overload fetch_coefficients(*units)
  #   @param units [Array<Object>]
  #   @return [Array<Numeric>]
  # @overload fetch_coefficients(*units) { |unit| ... }
  #   @param units [Array<Object>]
  #   @yieldparam unit [Object]
  #   @yieldreturn [Any]
  #   @return [Array<Any>]
  # @raise [KeyError] if default value was needed, but not provided
  #
  # @since <<next>>
  def fetch_coefficients(...)
    @data.fetch_values(...) # steep:ignore UnresolvedOverloading
  end

  alias fetch_values fetch_coefficients

  # Check if a unit has a non-zero coefficient.
  #
  # @example
  #   VectorNumber["a", "b", 6].unit?("a") # => true
  #   VectorNumber["a", "b", 6].key?("c") # => false
  #
  # @param unit [Object]
  # @return [Boolean]
  #
  # @since 0.2.4
  def unit?(unit)
    @data.key?(unit)
  end

  # @since 0.2.4
  alias key? unit?
end
