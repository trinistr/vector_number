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
  #   @yieldparam unit [Any]
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
  # @return [Array<Any>]
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
  # @param units [Array<Any>]
  # @return [Array<Numeric>]
  #
  # @since <<next>>
  def coefficients_at(*units)
    @data.values_at(*units) # : Array[coefficient_type]
  end

  # @since <<next>>
  alias values_at coefficients_at

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
  # @param unit [Any]
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
  # @param unit [Any]
  # @return [Array(Any, Numeric)]
  #
  # @since <<next>>
  def assoc(unit)
    @data.assoc(unit) || [unit, 0]
  end

  # Finds and returns the object in nested objects that is specified by +identifiers+.
  #
  # As nested objects for a VectorNumber are numeric coefficients,
  # digging deeper will most probably result in an error.
  #
  # @example
  #   VectorNumber["a", "b", 6].dig("a") # => 1
  #   VectorNumber["a", "b", 6].dig("c") # => 0
  #   VectorNumber["a", "b", 6].dig("a", 1) # TypeError
  #   { 1 => VectorNumber["a", "b", 6] }.dig(1, "a") # => 1
  #
  # @param identifiers [Array<Any>]
  # @return [Numeric]
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
  #   @param unit [Any]
  #   @return [Numeric]
  # @overload fetch(unit, default_value)
  #   @param unit [Any]
  #   @param default_value [Any]
  #   @return [Any]
  # @overload fetch(unit)
  #   @param unit [Any]
  #   @yieldparam unit [Any]
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
  #   @param units [Array<Any>]
  #   @return [Array<Numeric>]
  # @overload fetch_coefficients(*units)
  #   @param units [Array<Any>]
  #   @yieldparam unit [Any]
  #   @yieldreturn [Any]
  #   @return [Array<Any>]
  # @raise [KeyError] if default value was needed, but not provided
  #
  # @since <<next>>
  def fetch_coefficients(...)
    @data.fetch_values(...) # steep:ignore UnresolvedOverloading
  end

  # @since <<next>>
  alias fetch_values fetch_coefficients

  # Check if a unit has a non-zero coefficient.
  #
  # @example
  #   VectorNumber["a", "b", 6].unit?("a") # => true
  #   VectorNumber["a", "b", 6].key?("c") # => false
  #
  # @param unit [Any]
  # @return [Boolean]
  #
  # @since 0.2.4
  def unit?(unit)
    @data.key?(unit)
  end

  # @since 0.2.4
  alias key? unit?

  # Return a new VectorNumber with coefficients transformed
  # by the mapping hash and/or a block.
  #
  # An optional +mapping+ argument can be provided to map coefficients to new coefficients.
  # Any coefficient not given in +mapping+ will be mapped using the provided block,
  # or remain the same if no block is given.
  # If neither +mapping+ nor block is given, an enumerator is returned.
  #
  # @example
  #   VectorNumber["a", "b", 6].transform_coefficients { _1 * 2 } # => (2⋅"a" + 2⋅"b" + 12)
  #   VectorNumber["a", "b", 6].transform_values(1 => 2) # => (2⋅"a" - 2⋅"b" + 6)
  #   VectorNumber["a", "b", 6].transform_coefficients(1 => 2) { _1 / 2 } # => (2⋅"a" - 2⋅"b" + 3)
  #   VectorNumber["a", "b", 6].transform_values # => Enumerator
  #
  # @overload transform_coefficients(mapping)
  #   @param mapping [Hash{Numeric => Numeric}]
  #   @return [VectorNumber]
  # @overload transform_coefficients
  #   @yieldparam coefficient [Numeric]
  #   @yieldreturn [Numeric]
  #   @return [VectorNumber]
  # @overload transform_coefficients(mapping)
  #   @param mapping [Hash{Numeric => Numeric}]
  #   @yieldparam coefficient [Numeric]
  #   @yieldreturn [Numeric]
  #   @return [VectorNumber]
  # @overload transform_coefficients
  #   @return [Enumerator]
  #
  # @since <<next>>
  def transform_coefficients(mapping = nil, &transform)
    if mapping
      if block_given?
        # @type var transform: ^(coefficient_type) -> coefficient_type
        new { |c| mapping.fetch(c) { yield(c) } }
      else
        new { |c| mapping.fetch(c, c) }
      end
    elsif block_given?
      # @type var transform: ^(coefficient_type) -> coefficient_type
      new(&transform)
    else
      to_enum(:transform_coefficients) { size } # rubocop:disable Lint/ToEnumArguments
    end
  end

  # @since <<next>>
  alias transform_values transform_coefficients

  # Return a new VectorNumber with units transformed
  # by the mapping hash and/or a block.
  #
  # An optional +mapping+ argument can be provided to map units to new units.
  # Any unit not given in +mapping+ will be mapped using the provided block,
  # or remain the same if no block is given.
  # If neither +mapping+ nor block is given, an enumerator is returned.
  #
  # @example
  #   VectorNumber["a", "b", 6].transform_units("a" => "c") # => (1⋅"c" + 1⋅"b" + 6)
  #   VectorNumber["a", "b", 6].transform_keys { _1.is_a?(String) ? _1.to_sym : _1 }
  #     # => (1⋅:a + 1⋅:b + 6)
  #   VectorNumber["a", "b", 6].transform_units("a" => "c") { _1.to_s }
  #     # => (1⋅"c" + 1⋅"b" + 6⋅"")
  #   VectorNumber["a", "b", 6].transform_keys # => Enumerator
  #
  # @overload transform_units(mapping)
  #   @param mapping [Hash{Any => Any}]
  #   @return [VectorNumber]
  # @overload transform_units
  #   @yieldparam unit [Any]
  #   @yieldreturn [Any]
  #   @return [VectorNumber]
  # @overload transform_units(mapping)
  #   @param mapping [Hash{Any => Any}]
  #   @yieldparam unit [Any]
  #   @yieldreturn [Any]
  #   @return [VectorNumber]
  # @overload transform_units
  #   @return [Enumerator]
  #
  # @since <<next>>
  def transform_units(mapping = nil, &transform)
    if block_given?
      # @type var transform: ^(unit_type unit) -> unit_type
      if mapping
        new(@data.transform_keys(mapping, &transform))
      else
        new(@data.transform_keys(&transform))
      end
    elsif mapping
      new(@data.transform_keys(mapping))
    else
      to_enum(:transform_units) { size } # rubocop:disable Lint/ToEnumArguments
    end
  end

  # @since <<next>>
  alias transform_keys transform_units
end
