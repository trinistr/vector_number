# frozen_string_literal: true

class VectorNumber
  # @group Similarity measures

  # Calculate cosine between this vector and +other+.
  #
  # Cosine can be used as a measure of similarity.
  #
  # @example
  #   v = VectorNumber[2, "a"]
  #   v.cosine(v) # => 1.0
  #   v.cosine_similarity(1) # => 0.8944271909999159
  #   v.cosine("b") # => 0.0
  #   v.cosine_similarity(-v) # => -1.0
  #   v.cosine(0) # ZeroDivisionError
  #   VectorNumber[0].cosine(v) # ZeroDivisionError
  #
  # @see #angle
  #
  # @param other [VectorNumber, Any]
  # @return [Numeric]
  # @raise [ZeroDivisionError] if either +self+ or +other+ is a zero vector
  #
  # @since 0.7.0
  def cosine(other)
    has_direction?
    return 1.0 if equal?(other)

    other = new([other]) unless VectorNumber === other
    has_direction?(other)
    return 0.0 if (product = dot_product(other)).zero?

    # Due to precision errors, the result might be slightly outside [-1, 1], so we clamp.
    (product / magnitude / other.magnitude).clamp(-1.0, 1.0)
  end

  # @since 0.7.0
  alias cosine_similarity cosine

  # Calculate Jaccard index of similarity between this vector and +other+.
  #
  # This measure is binary: it considers only sets of non-zero dimensions in vectors,
  # ignoring coefficients.
  #
  # @example
  #   v = VectorNumber[2, "a"]
  #   v.jaccard_index(v) # => (1/1)
  #   v.jaccard_index(1) # => (1/2)
  #   v.jaccard_index("b") # => (0/1)
  #   v.jaccard_index(-v) # => (1/1)
  #   v.jaccard_index(0) # => (0/1)
  #   VectorNumber[0].jaccard_index(v) # => (0/1)
  #   VectorNumber[0].jaccard_index(0) # ZeroDivisionError
  #
  # @see #jaccard_similarity
  #
  # @param other [VectorNumber, Any]
  # @return [Rational]
  # @raise [ZeroDivisionError] if both vectors are zero vectors
  #
  # @since 0.7.0
  def jaccard_index(other)
    other = new([other]) unless VectorNumber === other
    intersection = units.intersection(other.units)
    Rational(intersection.size, size + other.size - intersection.size)
  end

  # Calculate weighted Jaccard similarity index between this vector and +other+.
  #
  # This measure only makes sense for non-negative vectors.
  #
  # @example
  #   v = VectorNumber[2, "a"]
  #   v.jaccard_similarity(v) # => (1/1)
  #   v.jaccard_similarity(1) # => (1/3)
  #   v.jaccard_similarity("b") # => (0/1)
  #   v.jaccard_similarity(-v) # => (-1/1)
  #   v.jaccard_similarity(0) # => (0/1)
  #   VectorNumber[0].jaccard_similarity(v) # => (0/1)
  #   VectorNumber[0].jaccard_similarity(0) # ZeroDivisionError
  #
  # @see #jaccard_index
  #
  # @param other [VectorNumber, Any]
  # @return [Rational]
  # @raise [ZeroDivisionError] if both vectors are zero vectors
  #
  # @since 0.7.0
  def jaccard_similarity(other)
    other = new([other]) unless VectorNumber === other
    Rational(
      @data.sum { |u, c| [c, other[u]].min },
      units.union(other.units).sum { |u| [self[u], other[u]].max }
    )
  end
end
