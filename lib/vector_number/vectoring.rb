# frozen_string_literal: true

class VectorNumber
  # @group Vector operations

  # Calculate the absolute value of the vector (its magnitude/length).
  #
  # This is also known as Euclidean norm or 2-norm.
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

  # @since 0.2.2
  alias magnitude abs
  # @since <<next>>
  alias euclidean_norm abs

  # Calculate the square of absolute value.
  #
  # @example
  #   VectorNumber[5.3].abs2 # => 5.3
  #   VectorNumber[-5.3i].abs2 # => 5.3
  #   VectorNumber[-5.3i, "i"].abs2 # => 29.09
  #
  # @return [Numeric]
  #
  # @since 0.2.2
  def abs2
    @data.values.sum(&:abs2)
  end

  # Calculate the p-norm of the vector.
  #
  # @example
  #   VectorNumber[5.3].p_norm(2) # => 5.3
  #   VectorNumber[-5.3i].p_norm(2) # => 5.3
  #   VectorNumber[-5.3i, "i"].p_norm(2) # => 5.3935146240647205
  #
  # @return [Float]
  #
  # @since <<next>>
  def p_norm(power)
    @data.values.sum { _1.abs**power }**(1.0 / power)
  end

  # Calculate the maximum norm (infinity norm) of the vector.
  #
  # @example
  #   VectorNumber[5.3].maximum_norm # => 5.3
  #   VectorNumber[-5.3i].maximum_norm # => 5.3
  #   VectorNumber[-5.3i, "i"].maximum_norm # => 5.3
  #   VectorNumber["a", "s"].maximum_norm # => 1
  #
  # @return [Numeric]
  #
  # @since <<next>>
  def maximum_norm
    return 0 if zero?

    @data.values.map(&:abs).max
  end

  alias infinity_norm maximum_norm

  # Return an array of vectors forming orthonormal basis
  # of linear subspace this vector belongs to.
  #
  # @example
  #   v = VectorNumber[1.2, "a"] * 2 - "s" # => (2.4 + 2⋅"a" - 1⋅"s")
  #   v.subspace_basis # => [(1), (1⋅"a"), (1⋅"s")]
  #   VectorNumber[0].subspace_basis # => []
  #
  # @see #uniform_vector
  #
  # @return [Array<VectorNumber>]
  #
  # @since <<next>>
  def subspace_basis
    units.map { new([_1]) }
  end

  # Return a new vector with the same non-zero dimensions,
  # but with coefficients equal to 1.
  #
  # Resulting vector is equal to +self.subspace_basis.sum+.
  #
  # @example
  #   v = VectorNumber[1.2, "a"] * 2 - "s" # => (2.4 + 2⋅"a" - 1⋅"s")
  #   v.uniform_vector # => (1 + 1⋅"a" + 1⋅"s")
  #   VectorNumber[0].uniform_vector # => (0)
  #
  # @see #subspace_basis
  #
  # @return [VectorNumber]
  #
  # @since <<next>>
  def uniform_vector
    new { 1 }
  end

  # Return a unit vector (vector with magnitude 1) in the direction of this vector.
  #
  # Magnitude of resulting vector may not be exactly 1 due to rounding errors.
  #
  # @example
  #   v = VectorNumber[1.2, "a"] * 2 - "s" # => (2.4 + 2⋅"a" - 1⋅"s")
  #   v.unit_vector # => (0.7316529130196309 + 0.6097107608496924⋅"a" - 0.3048553804248462⋅"s")
  #   v.unit_vector.magnitude # => 1.0
  #   VectorNumber[0].unit_vector # ZeroDivisionError
  #
  # @return [VectorNumber]
  # @raise [ZeroDivisionError] if +self+ is a zero vector
  #
  # @since <<next>>
  def unit_vector
    check_directionality(self)

    self / magnitude
  end

  # Calculate the dot (inner/scalar) product of this vector with +other+ vector.
  #
  # If +other+ is not a VectorNumber, it is automatically promoted.
  #
  # @example
  #   VectorNumber[2].dot_product(VectorNumber[3]) # => 6
  #   v = VectorNumber[2, "a"]
  #   v.dot_product(VectorNumber[3, "s"]) # => 6
  #   v.dot_product(3) # => 6
  #   v.dot_product("b") # => 0
  #   v.dot_product(0) # => 0
  #   VectorNumber[0].dot_product(v) # => 0
  #   v.dot_product(v) == v.abs2 # => true
  #
  # @param other [VectorNumber, Object]
  # @return [Numeric]
  #
  # @since <<next>>
  def dot_product(other)
    return 0 if zero?
    return abs2 if equal?(other)

    other = new([other]) unless other.is_a?(VectorNumber)
    @data.sum { |u, c| c * other[u] }
  end

  # @since <<next>>
  alias inner_product dot_product
  # @since <<next>>
  alias scalar_product dot_product

  # Calculate the angle between this vector and +other+ vector in radians.
  #
  # If +other+ is not a VectorNumber, it is automatically promoted.
  #
  # @example
  #   v = VectorNumber[2, "a"]
  #   v.angle(v) # => 0.0
  #   v.angle(1) # => 0.7853981633974483
  #   v.angle("b") # => 1.5707963267948966
  #   v.angle(-v) # => 3.141592653589793
  #   v.angle(0) # ZeroDivisionError
  #   VectorNumber[0].angle(v) # ZeroDivisionError
  #
  # @param other [VectorNumber, Object]
  # @return [Float]
  # @raise [ZeroDivisionError] if +self+ or +other+ is a zero vector
  #
  # @since <<next>>
  def angle(other)
    check_directionality(self)
    return 0.0 if equal?(other)

    other = new([other]) unless other.is_a?(VectorNumber)
    check_directionality(other)
    return Math::PI / 2.0 if (product = dot_product(other)).zero?

    Math.acos(product / (magnitude * other.magnitude))
  end

  # Calculate the vector projection of this vector onto +other+ vector.
  #
  # If +other+ is not a VectorNumber, it is automatically promoted.
  #
  # @example
  #   v = VectorNumber[2, "a"]
  #   v.vector_projection(v) # => (2.0 + 1.0⋅"a")
  #   v.vector_projection(1) # => (2.0)
  #   v.vector_projection("b") # => (0)
  #   v.vector_projection(-v) # => (-2.0 - 1.0⋅"a")
  #   VectorNumber[0].vector_projection(v) # => (0)
  #   v.vector_projection(0) # ZeroDivisionError
  #
  # @param other [VectorNumber, Object]
  # @return [VectorNumber]
  # @raise [ZeroDivisionError] if +other+ is a zero vector
  #
  # @since <<next>>
  def vector_projection(other)
    other = new([other]) unless other.is_a?(VectorNumber)
    check_directionality(other)

    other * dot_product(other) / other.abs2
  end

  # Calculate the scalar projection of this vector onto +other+ vector.
  #
  # Scalar projection is equal to {#magnitude} of {#vector_projection}.
  # If +other+ is not a VectorNumber, it is automatically promoted.
  #
  # @example
  #   v = VectorNumber[2, "a"]
  #   v.scalar_projection(v) # => 2.23606797749979
  #   v.scalar_projection(1) # => 2.0
  #   v.scalar_projection("b") # => 0.0
  #   v.scalar_projection(-v) # => -2.23606797749979
  #   VectorNumber[0].scalar_projection(v) # => 0
  #   v.scalar_projection(0) # ZeroDivisionError
  #
  # @param other [VectorNumber, Object]
  # @return [Float]
  # @raise [ZeroDivisionError] if +other+ is a zero vector
  #
  # @since <<next>>
  def scalar_projection(other)
    other = new([other]) unless other.is_a?(VectorNumber)
    check_directionality(other)

    dot_product(other) / other.magnitude
  end

  # Calculate the vector rejection of this vector from +other+ vector.
  #
  # Vector rejection is equal to +self - self.vector_projection(other)+.
  # If +other+ is not a VectorNumber, it is automatically promoted.
  #
  # @example
  #   v = VectorNumber[2, "a"]
  #   v.vector_rejection(v) # => (0)
  #   v.vector_rejection(1) # => (1⋅"a")
  #   v.vector_rejection("b") # => (2 + 1⋅"a")
  #   v.vector_rejection(-v) # => (0)
  #   VectorNumber[0].vector_rejection(v) # => (0)
  #   v.vector_rejection(0) # ZeroDivisionError
  #
  # @param other [VectorNumber, Object]
  # @return [VectorNumber]
  # @raise [ZeroDivisionError] if +other+ is a zero vector
  #
  # @since <<next>>
  def vector_rejection(other)
    other = new([other]) unless other.is_a?(VectorNumber)
    check_directionality(other)

    self - vector_projection(other)
  end

  # Calculate the scalar rejection of this vector from +other+ vector.
  #
  # Scalar rejection is equal to {#magnitude} of {#vector_rejection}.
  # If +other+ is not a VectorNumber, it is automatically promoted.
  #
  # @example
  #   v = VectorNumber[2, "a"]
  #   v.scalar_rejection(v) # => 0.0
  #   v.scalar_rejection(1) # => 1.0
  #   v.scalar_rejection("b") # => 2.23606797749979
  #   v.scalar_rejection(-v) # => 0.0
  #   VectorNumber[0].scalar_rejection(v) # => 0.0
  #   v.scalar_rejection(0) # ZeroDivisionError
  #
  # @param other [VectorNumber, Object]
  # @return [Float]
  # @raise [ZeroDivisionError] if +other+ is a zero vector
  #
  # @since <<next>>
  def scalar_rejection(other)
    other = new([other]) unless other.is_a?(VectorNumber)
    check_directionality(other)

    vector_rejection(other).magnitude
  end

  private

  def check_directionality(vector)
    raise ZeroDivisionError, "direction is undefined for a zero vector", caller if vector.zero?
  end
end
