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
  #   VectorNumber["a", "b", 6]["c"] # => 0
  #
  # @param unit [Object]
  # @return [Numeric]
  #
  # @since 0.2.4
  def [](unit) = @data[unit]

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
  def unit?(unit) = @data.key?(unit)

  # @since 0.2.4
  alias key? unit?
end
