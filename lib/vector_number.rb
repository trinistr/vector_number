# frozen_string_literal: true

# VectorNumber provides a Numeric-like experience for doing arithmetics on heterogeneous objects,
# with more advanced operations based on real vector spaces available when needed.
#
# VectorNumber inherits from +Object+ and includes +Enumerable+ and +Comparable+.
# It implements mostly the same interface as +Numeric+ classes, but can {#coerce} any value.
# Its behavior follows +Complex+ when reasonable.
#
# All instances are frozen after creation.
#
# **Working** **with** **numeric** **units**
#
# Real and imaginary units are represented by {R} and {I} constants, not numbers,
# as may be expected. They are instances of {SpecialUnit} class which has useful
# behavior. However, they are not equal to any object besides themselves, which
# necessitates always using these constants, not new objects.
#
# User must use these specific constants when
# - initializing vector using a hash,
# - accessing vector by unit.
#
# Customizing {#to_s} result should also check for these using {.numeric_unit?},
# or, alternatively, for all {SpecialUnit}s with {.unit?}.
#
# @since 0.1.0
class VectorNumber
  require_relative "vector_number/comparing"
  require_relative "vector_number/converting"
  require_relative "vector_number/enumerating"
  require_relative "vector_number/mathing"
  require_relative "vector_number/querying"
  require_relative "vector_number/rounding"
  require_relative "vector_number/similarity"
  require_relative "vector_number/stringifying"
  require_relative "vector_number/vectoring"
  require_relative "vector_number/version"

  require_relative "vector_number/special_unit"

  # List of special numeric unit constants.
  #
  # @since 0.6.0
  NUMERIC_UNITS = [SpecialUnit.new("1", "").freeze, SpecialUnit.new("i").freeze].freeze
  # Constant for real unit (1).
  #
  # Its string representation is an empty string.
  #
  # @since 0.6.0
  R = NUMERIC_UNITS[0]
  # Constant for imaginary unit (i).
  #
  # Its string representation is "i".
  #
  # @since 0.6.0
  I = NUMERIC_UNITS[1]

  # @group Creation
  # Create new VectorNumber from a list of values or a hash.
  #
  # @example list mode
  #   VectorNumber[1, 2, 3] # => (6)
  #   VectorNumber[[1, 2, 3]] # => (1⋅[1, 2, 3])
  #   VectorNumber[] # => (0)
  #   VectorNumber["b", VectorNumber["b"]] # => (2⋅"b")
  #   VectorNumber["a", "b", "a"] # => (2⋅"a" + 1⋅"b")
  #   VectorNumber[{"a" => 2, "b" => 1.5}] # => (1⋅{"a" => 2, "b" => 1.5})
  # @example hash mode
  #   VectorNumber["a" => 2, "b" => 1.5] # => (2⋅"a" + 1.5⋅"b")
  #   VectorNumber["a" => 2, ["b"] => 1.5, {a: 2} => -1] # => (2⋅"a" + 1.5⋅["b"] - 1⋅{a: 2})
  #   VectorNumber[:s => 5, VectorNumber::R => 13, :l => -3, VectorNumber::I => -2.5]
  #     # => (5⋅:s + 13 - 3⋅:l - 2.5i)
  # @example mixing modes doesn't work
  #   VectorNumber["b", "a", "a" => 2] # ArgumentError
  #   VectorNumber["a" => 2, "b", "a"] # SyntaxError
  #
  # @overload [](*values)
  #   @param values [Array<Any>] values to add together to produce a vector
  # @overload [](**hash_values)
  #   @param hash_values [Hash{Any => Numeric}] units and coefficients to create a vector
  # @return [VectorNumber]
  # @raise [ArgumentError, RangeError]
  def self.[](*values, **hash_values)
    raise ArgumentError, "no block accepted" if block_given?

    if !values.empty? # rubocop:disable Style/NegatedIfElseCondition
      unless hash_values.empty?
        raise ArgumentError, "either list of values or hash can be used, not both"
      end

      # @type var values : list[unit_type]
      new(values)
    else
      # @type var hash_values : Hash[unit_type, coefficient_type]
      new(hash_values)
    end
  end
  # @endgroup

  # @group Miscellaneous methods

  # Check if an object is a unit representing a numeric dimension
  # (real or imaginary unit).
  #
  # @example
  #   VectorNumber.numeric_unit?(VectorNumber::R) # => true
  #   VectorNumber.numeric_unit?(VectorNumber::I) # => true
  #   VectorNumber.numeric_unit?(VectorNumber::SpecialUnit.new("my")) # => false
  #   VectorNumber.numeric_unit?(:i) # => false
  #
  # @see .special_unit?
  #
  # @param unit [Any]
  # @return [Boolean]
  #
  # @since 0.6.0
  def self.numeric_unit?(unit)
    NUMERIC_UNITS.include?(unit) # steep:ignore ArgumentTypeMismatch
  end

  # Check if an object is a {SpecialUnit}. This includes numeric units.
  #
  # @example
  #   VectorNumber.special_unit?(VectorNumber::R) # => true
  #   VectorNumber.special_unit?(VectorNumber::SpecialUnit.new("my")) # => true
  #   VectorNumber.special_unit?(:i) # => false
  #
  # @see .numeric_unit?
  #
  # @param unit [Any]
  # @return [Boolean]
  #
  # @since 0.7.0
  def self.special_unit?(unit)
    SpecialUnit === unit
  end

  class << self
    # @since 0.7.0
    alias unit? special_unit?
  end

  # Number of non-zero dimensions.
  #
  # @return [Integer]
  attr_reader :size

  # @group Creation

  # Create new VectorNumber from +values+,
  # possibly modifying coefficients with a block.
  #
  # Using +VectorNumber.new+ directly is more efficient than +VectorNumber[...]+.
  #
  # +values+ can be:
  # - an array of values;
  # - a hash of units and coefficients;
  # - a VectorNumber to copy, most useful with a block;
  # - +nil+ to specify a 0-sized vector (same as an empty array or hash).
  #
  # @example
  #   VectorNumber.new(1, 2, 3) # ArgumentError
  #   VectorNumber.new([1, 2, 3]) # => (6)
  #   VectorNumber.new(["b", VectorNumber::I]) # => (1⋅"b" + 1i)
  #   VectorNumber.new # => (0)
  # @example with a block
  #   VectorNumber.new(["a", "b", "c", 3]) { _1 * 2 } # => (2⋅"a" + 2⋅"b" + 2⋅"c" + 6)
  #   VectorNumber.new(["a", "b", "c", 3], &:-@) # => (-1⋅"a" - 1⋅"b" - 1⋅"c" - 3)
  #   VectorNumber.new(["a", "b", "c", 3], &:digits) # RangeError
  # @example using hash for values
  #   v = VectorNumber.new({VectorNumber::R => 15, "a" => 3.4, nil => -3})
  #     # => (15 + 3.4⋅"a" - 3⋅nil)
  #   v.to_h # => {unit/1 => 15, "a" => 3.4, nil => -3}
  #   VectorNumber.new({15 => 1}) # RangeError
  #
  # @param values [Array, VectorNumber, Hash{Object => Numeric}, nil] values for this vector
  # @yieldparam coefficient [Numeric] a real number
  # @yieldreturn [Numeric] new coefficient
  # @raise [RangeError] if a coefficient is not a real number
  def initialize(values = nil, **nil, &transform)
    initialize_from(values)
    apply_transform(&transform)
    finalize_contents
    @data.freeze
    freeze
  end

  # @group Miscellaneous methods

  # Return self.
  #
  # @return [VectorNumber]
  #
  # @since 0.2.0
  def +@ = self
  # @since 0.2.4
  alias dup +@

  # Return self.
  #
  # @return [VectorNumber]
  # @raise [ArgumentError] if +freeze+ is not +true+ or +nil+.
  #
  # @since 0.2.4
  def clone(freeze: true)
    case freeze
    when true, nil
      self
    when false
      raise ArgumentError, "can't unfreeze VectorNumber"
    else
      raise ArgumentError,
            "unexpected value for freeze: #{Kernel.instance_method(:class).bind_call(freeze)}"
    end
  end

  private

  # Create new VectorNumber from a value or self, optionally applying a transform.
  #
  # @param from [VectorNumber, Array, Hash{Any => Numeric}] self if not specified
  # @yieldparam coefficient [Numeric] a real number
  # @yieldreturn [Numeric] new coefficient
  # @return [VectorNumber]
  def new(from = self, &transform)
    VectorNumber.new(from, &transform)
  end

  # Check if +other+ is a real number.
  #
  # Currently this is either a +real?+ Numeric or +numeric?(1)+ VectorNumber.
  #
  # @param value [Any]
  # @return [Boolean]
  def real_number?(value)
    (Numeric === value && value.real?) || (VectorNumber === value && value.numeric?(1))
  end

  # @param values [Array, Hash{Any => Numeric}, VectorNumber, nil]
  # @return [void]
  def initialize_from(values)
    @data = values.to_h and return if VectorNumber === values

    @data = Hash.new(0)
    case values
    when Array
      values.each { |value| add_value_to_data(value) }
    when Hash
      add_vector_to_data(values)
    when nil
      # Do nothing, as there are no values.
    else
      raise ArgumentError,
            "unsupported type for values: #{Kernel.instance_method(:class).bind_call(values)}"
    end
  end

  # @param value [VectorNumber, Numeric, Any]
  # @return [void]
  def add_value_to_data(value)
    case value
    when Numeric
      add_numeric_value_to_data(value)
    when VectorNumber
      add_vector_to_data(value)
    else
      @data[value] += 1
    end
  end

  # @param value [Numeric]
  # @return [void]
  def add_numeric_value_to_data(value)
    @data[R] += value.real # steep:ignore UnresolvedOverloading
    # Most numbers will be real, and this extra condition appreciably speeds up addition,
    # while having no noticeable impact on complex numbers.
    @data[I] += value.imaginary unless value.real? # steep:ignore UnresolvedOverloading
  end

  # @param vector [VectorNumber, Hash{Any => Numeric}]
  # @return [void]
  def add_vector_to_data(vector)
    vector.each_pair do |unit, coefficient|
      raise RangeError, "#{unit} is not allowed as a unit" if Numeric === unit
      raise RangeError, "#{coefficient} is not a real number" unless real_number?(coefficient)

      @data[unit] += coefficient.real # steep:ignore UnresolvedOverloading
    end
  end

  # @yieldparam coefficient [Numeric] a real number
  # @yieldreturn [Numeric] new coefficient
  # @return [void]
  # @raise [RangeError]
  def apply_transform
    return unless block_given?

    @data.transform_values! do |coefficient|
      new_value = yield coefficient
      next new_value.real if real_number?(new_value)

      raise RangeError, "transform returned non-real value for #{coefficient}"
    end
  end

  # Compact coefficients, calculate size and freeze data.
  # @return [void]
  def finalize_contents
    @data.delete_if { |_u, c| c.zero? }
    @data.freeze
    @size = @data.size
  end
end
