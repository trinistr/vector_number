# frozen_string_literal: true

require_relative "vector_number/version"
require_relative "vector_number/mathing"
require_relative "vector_number/math_converting"
require_relative "vector_number/converting"
require_relative "vector_number/enumerating"
require_relative "vector_number/comparing"
require_relative "vector_number/querying"
require_relative "vector_number/stringifying"

# A class to add together anything.
class VectorNumber
  include Mathing
  include MathConverting
  include Converting
  include Enumerating
  include Comparing
  include Querying
  include Stringifying

  # Keys for possible options.
  # Unknown options will be rejected when creating a vector.
  #
  # @return [Array<Symbol>]
  #
  # @since 0.2.0
  KNOWN_OPTIONS = %i[mult].freeze

  # Default values for options.
  #
  # @return [Hash{Symbol => Object}]
  #
  # @since 0.2.0
  DEFAULT_OPTIONS = { mult: :dot }.freeze

  # Get a unit for +n+th numeric dimension, where 1 is real, 2 is imaginary.
  #
  # @since 0.2.0
  UNIT = ->(n) { (n - 1).i }.freeze
  # Constant for real unit.
  #
  # @since 0.2.0
  R = UNIT[1]
  # Constant for imaginary unit.
  #
  # @since 0.1.0
  I = UNIT[2]

  # Number of non-zero dimensions.
  #
  # @return [Integer]
  #
  # @since 0.1.0
  attr_reader :size

  # Options used for this vector.
  #
  # @see KNOWN_OPTIONS
  #
  # @return [Hash{Symbol => Object}]
  #
  # @since 0.1.0
  attr_reader :options

  # Create new VectorNumber from +values+, possibly specifying +options+.
  #
  # @example
  #   VectorNumber[1, 2, 3] #=> (6)
  #   VectorNumber[[1, 2, 3]] #=> (1⋅[1, 2, 3])
  #   VectorNumber['b', VectorNumber::I, mult: :asterisk] #=> (1*'b' + 1i)
  #   VectorNumber[] #=> (0)
  # @param values [Array<Object>] values to put in the number
  # @param options [Hash{Symbol => Object}] options for the number
  # @option options [Symbol, String] :mult Multiplication symbol,
  #   either a key from {MULT_STRINGS} or a literal string to use
  # @return [VectorNumber]
  #
  # @since 0.1.0
  def self.[](*values, **options)
    new(values, options)
  end

  # @param values [Array, Hash{Object => Integer, Float, Rational, BigDecimal}, VectorNumber]
  #   values for this number, hashes are treated like plain vector numbers
  # @param options [Hash{Symbol => Object}]
  #   options for this number, if +values+ is a VectorNumber or contains it,
  #   these will be merged with options from its +options+
  # @option options [Symbol, String] :mult
  #   text to use between unit and coefficient, see {Stringifying#to_s} for explanation
  # @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
  # @yieldreturn [Integer, Float, Rational, BigDecimal] new coefficient
  # @raise [RangeError] if any pesky non-reals get where they shouldn't
  def initialize(values = nil, options = nil, &)
    # @type var options: Hash[Symbol, Object]
    initialize_from(values)
    apply_transform(&)
    finalize_contents
    save_options(options, values:)
    @options.freeze
    @data.freeze
    freeze
  end

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
  # @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
  # @yieldreturn [Integer, Float, Rational, BigDecimal] new coefficient
  # @return [VectorNumber]
  def new(from = self, &)
    self.class.new(from, options, &)
  end

  # Check if +other+ is a real number.
  #
  # Currently this is either a +real?+ Numeric or +numeric?(1)+ VectorNumber.
  #
  # @param value [Object]
  # @return [Boolean]
  #
  # @since 0.1.0
  def real_number?(value)
    (value.is_a?(Numeric) && value.real?) || (value.is_a?(self.class) && value.numeric?(1))
  end

  # @param values [Array, Hash{Object => Integer, Float, Rational, BigDecimal}, VectorNumber, nil]
  # @return [void]
  #
  # @since 0.1.0
  def initialize_from(values)
    @data = Hash.new(0)

    case values
    when VectorNumber, Hash
      add_vector_to_data(values)
    when Array
      values.each { |value| add_value_to_data(value) }
    else
      # Don't add anything.
    end
  end

  # @param value [VectorNumber, Numeric, Object]
  # @return [void]
  #
  # @since 0.1.0
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
  #
  # @since 0.1.0
  def add_numeric_value_to_data(value)
    @data[R] += value.real
    @data[I] += value.imaginary
  end

  # @param vector [VectorNumber, Hash{Object => Integer, Float, Rational, BigDecimal}]
  # @return [void]
  #
  # @since 0.1.0
  def add_vector_to_data(vector)
    vector.each_pair do |unit, coefficient|
      raise RangeError, "#{coefficient} is not a real number" unless real_number?(coefficient)

      @data[unit] += coefficient.real
    end
  end

  # @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
  # @yieldreturn [Integer, Float, Rational, BigDecimal]
  # @return [void]
  # @raise [RangeError]
  #
  # @since 0.1.0
  def apply_transform
    return unless block_given?

    @data.transform_values! do |coefficient|
      new_value = yield coefficient
      next new_value.real if real_number?(new_value)

      raise RangeError, "transform returned non-real value for #{coefficient}"
    end
  end

  # @param options [Hash{Symbol => Object}, nil]
  # @param values [Object] initializing object
  # @return [void]
  #
  # @since 0.1.0
  def save_options(options, values:)
    @options =
      case [options, values]
      in [{} | nil, VectorNumber]
        values.options
      in [{} | nil, [*, VectorNumber => vector, *]]
        vector.options
      in Hash, VectorNumber
        merge_options(values.options, options)
      in Hash, [*, VectorNumber => vector, *]
        merge_options(vector.options, options)
      in Hash, _ unless options.empty?
        merge_options(default_options, options)
      else
        default_options
      end
  end

  # @param base_options [Hash{Symbol => Object}]
  # @param added_options [Hash{Symbol => Object}]
  # @return [Hash{Symbol => Object}]
  #
  # @since 0.3.0
  def merge_options(base_options, added_options)
    # Optimization for the common case of passing options through #new.
    return base_options if added_options.equal?(base_options)

    base_options.merge(added_options).slice(*known_options)
  end

  # Compact coefficients, calculate size and freeze data.
  # @return [void]
  #
  # @since 0.1.0
  def finalize_contents
    @data.delete_if { |_u, c| c.zero? }
    @data.freeze
    @size = @data.size
  end

  # @since 0.2.0
  def default_options
    DEFAULT_OPTIONS
  end

  # @since 0.2.0
  def known_options
    KNOWN_OPTIONS
  end
end
