# frozen_string_literal: true

# VectorNumber provides a Numeric-like experience for doing arithmetics on heterogeneous objects,
# with more advanced operations based on real vector spaces available when needed.
#
# VectorNumber inherits from +Object+ and includes +Enumerable+ and +Comparable+.
# It implements mostly the same interface as +Numeric+ classes, but can {#coerce} any value.
# Its behavior follows +Complex+ when possible.
#
# All instances are frozen after creation.
#
# **Creation**
# - {.[]}: the simplest way to create a VectorNumber
# - {#initialize}: an alternative way, with some advanced features
#
# **Comparing**
# - {#==}: test for equal value
# - {#eql?}: test for equal value and type
# - {#<=>}: compare real values
# - {#hash}: calculate hash value for use in +Hash+es
#
# **Querying**
# - {#zero?}: check if all coefficients are zero
# - {#nonzero?}: check if any coefficient is non-zero
# - {#positive?}: check if all coefficients are positive
# - {#negative?}: check if all coefficients are negative
# - {#finite?}: check if all coefficients are finite
# - {#infinite?}: check if any coefficient is non-finite
# - {#numeric?}: test if value is real or complex
# - {#nonnumeric?}: test if value is not real or complex
# - {#integer?}: +false+
# - {#real?}: +false+
#
# **Arithmetic** **operations**
# - {#-@}/{#neg}: negate value
# - {#coerce}: convert any object to a VectorNumber
# - {#+}/{#add}: add object (vector addition)
# - {#-}/{#sub}: subtract object (vector subtraction)
# - {#*}/{#mult}: multiply (scale) by a real number
# - {#/}/{#quo}: divide (scale) by a real number
# - {#fdiv}: divide (scale) by a real number, using +fdiv+
# - {#div}: perform integer division, rounding towards -∞
# - {#ceildiv}: perform integer division, rounding towards +∞
# - {#%}/{#modulo}: return modulus from integer division ({#div})
# - {#divmod}: combination of {#div} and {#modulo}
# - {#remainder}: return remainder from integer division
#
# **Rounding**
# - {#round}: round each coefficient
# - {#ceil}: round each coefficient up towards +∞
# - {#floor}: round each coefficient down towards -∞
# - {#truncate}: truncate each coefficient towards 0
#
# **Vector** **operations**
# - {#magnitude}/{#abs}: calculate magnitude (length/absolute value)
# - {#abs2}: calculate square of absolute value
# - {#p_norm}: calculate p-norm of the vector
# - {#maximum_norm}/{#infinity_norm}: calculate maximum norm of the vector
# - {#subspace_basis}: return an array of vectors forming orthonormal basis
# - {#uniform_vector}: return a new vector with coefficients set to 1
# - {#unit_vector}: return a unit vector in the direction of this vector
# - {#dot_product}/{#inner_product}/{#scalar_product}: calculate the inner product of vectors
# - {#angle}: calculate angle between vectors
# - {#vector_projection}: calculate the vector projection onto another vector
# - {#scalar_projection}: calculate the scalar projection onto another vector
# - {#vector_rejection}: calculate the vector rejection from another vector
# - {#scalar_rejection}: calculate the scalar rejection from another vector
#
# **Type** **conversion**
# - {#real}: return real part
# - {#imag}/{#imaginary}: return imaginary part
# - {#to_i}/{#to_int}: convert to +Integer+ if possible
# - {#to_f}: convert to +Float+ if possible
# - {#to_r}: convert to +Rational+ if possible
# - {#to_d}: convert to +BigDecimal+ if possible
# - {#to_c}: convert to +Complex+ if possible
#
# **Hash-like** **operations**
# - {#each}/{#each_pair}: iterate through every pair of unit and coefficient
# - {#[]}: get coefficient by unit
# - {#unit?}/{#key?}: check if a unit has a non-zero coefficient
# - {#units}/{#keys}: return an array of units
# - {#coefficients}/#{values}: return an array of coefficients
# - {#to_h}: convert to Hash
#
# **Miscellaneous** **methods**
# - {.numeric_unit?}: check if a unit represents a numeric dimension
# - {#size}: number of non-zero dimensions
# - {#to_s}: return string representation suitable for output
# - {#inspect}: return string representation suitable for display
# - {#dup}/{#+}: return self
# - {#clone}: return self
#
# @since 0.1.0
class VectorNumber
  require_relative "vector_number/comparing"
  require_relative "vector_number/converting"
  require_relative "vector_number/enumerating"
  require_relative "vector_number/math_converting"
  require_relative "vector_number/mathing"
  require_relative "vector_number/querying"
  require_relative "vector_number/stringifying"
  require_relative "vector_number/vectoring"
  require_relative "vector_number/version"

  require_relative "vector_number/special_unit"

  # List of special numeric unit constants.
  #
  # @since 0.6.0
  NUMERIC_UNITS = [SpecialUnit.new("1", "").freeze, SpecialUnit.new("i", "i").freeze].freeze
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
  # Create new VectorNumber from a list of values.
  #
  # @example
  #   VectorNumber[1, 2, 3] # => (6)
  #   VectorNumber[[1, 2, 3]] # => (1⋅[1, 2, 3])
  #   VectorNumber[] # => (0)
  #   VectorNumber["b", VectorNumber["b"]] # => (2⋅'b')
  #   VectorNumber["a", "b", "a"] # => (2⋅'a' + 1⋅'b')
  #
  # @param values [Array<Object>] values to put in the number
  def self.[](*values, **nil)
    new(values)
  end
  # @endgroup

  # @group Miscellaneous methods

  # Check if an object is a unit representing a numeric dimension
  # (real or imaginary unit).
  #
  # @example
  #   VectorNumber.numeric_unit?(VectorNumber::R) # => true
  #   VectorNumber.numeric_unit?(VectorNumber::I) # => true
  #   VectorNumber.numeric_unit?(:i) # => false
  #
  # @param unit [Object]
  # @return [Boolean]
  #
  # @since 0.6.0
  def self.numeric_unit?(unit)
    NUMERIC_UNITS.include?(unit)
  end

  # Number of non-zero dimensions.
  #
  # @return [Integer]
  attr_reader :size

  # @group Creation

  # Create new VectorNumber from +values+,
  # possibly modifying coefficients with a block.
  #
  # Using +VectorNumber.new([values...])+ directly is more efficient than +VectorNumber[values...]+.
  #
  # +values+ can be:
  # - an array of values (see {.[]});
  # - a VectorNumber to copy;
  # - a hash in the format returned by {#to_h};
  # - +nil+ to specify a 0-sized vector (same as an empty array or hash).
  #
  # Using a hash as +values+ is an advanced technique which allows to quickly
  # construct a VectorNumber with desired units and coefficients,
  # but it can also lead to unexpected results if care is not taken
  # to provide only valid keys and values.
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
  #   v = VectorNumber.new({VectorNumber::R => 15, "a" => 3.4, nil => -3}) # => (15 + 3.4⋅"a" - 3⋅)
  #   v.to_h # => {unit/1 => 15, "a" => 3.4, nil => -3}
  #
  # @param values [Array, VectorNumber, Hash{Object => Numeric}, nil] values for this vector
  # @yieldparam coefficient [Numeric] a real number
  # @yieldreturn [Numeric] new coefficient
  # @raise [RangeError] if a block is used and it returns a non-number or non-real number
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
      raise ArgumentError, "can't unfreeze #{self.class}"
    else
      raise ArgumentError, "unexpected value for freeze: #{freeze.class}"
    end
  end

  private

  # Create new VectorNumber from a value or self, optionally applying a transform.
  #
  # @param from [Object] self if not specified
  # @yieldparam coefficient [Numeric] a real number
  # @yieldreturn [Numeric] new coefficient
  # @return [VectorNumber]
  def new(from = self, &transform)
    self.class.new(from, &transform)
  end

  # Check if +other+ is a real number.
  #
  # Currently this is either a +real?+ Numeric or +numeric?(1)+ VectorNumber.
  #
  # @param value [Object]
  # @return [Boolean]
  def real_number?(value)
    (value.is_a?(Numeric) && value.real?) || (value.is_a?(self.class) && value.numeric?(1))
  end

  # @param values [Array, Hash{Object => Numeric}, VectorNumber, nil]
  # @return [void]
  def initialize_from(values)
    @data = values.to_h and return if values.is_a?(VectorNumber)

    @data = Hash.new(0)
    case values
    when Array
      values.each { |value| add_value_to_data(value) }
    when Hash
      add_vector_to_data(values)
    when nil
      # Do nothing, as there are no values.
    else
      raise ArgumentError, "unsupported type for values: #{values.class}"
    end
  end

  # @param value [VectorNumber, Numeric, Object]
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
    @data[R] += value.real
    # Most numbers will be real, and this extra condition appreciably speeds up addition,
    # while having no noticeable impact on complex numbers.
    @data[I] += value.imaginary unless value.real?
  end

  # @param vector [VectorNumber, Hash{Object => Numeric}]
  # @return [void]
  def add_vector_to_data(vector)
    vector.each_pair do |unit, coefficient|
      raise RangeError, "#{coefficient} is not a real number" unless real_number?(coefficient)

      @data[unit] += coefficient.real
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
