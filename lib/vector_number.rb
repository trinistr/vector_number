# frozen_string_literal: true

require_relative "vector_number/version"
require_relative "vector_number/initializing"
require_relative "vector_number/mathing"
require_relative "vector_number/math_converting"
require_relative "vector_number/converting"
require_relative "vector_number/enumerating"
require_relative "vector_number/comparing"
require_relative "vector_number/querying"
require_relative "vector_number/stringifying"

# A class to add together anything.
class VectorNumber
  include Initializing
  include Mathing
  include MathConverting
  include Converting
  include Enumerating
  include Comparing
  include Querying
  include Stringifying

  # @return [Array<Symbol>]
  KNOWN_OPTIONS = %i[mult].freeze

  # @return [Hash{Symbol => Object}]
  DEFAULT_OPTIONS = { mult: :dot }.freeze

  # Get a unit for +n+th numeric dimension, where 1 is real, 2 is imaginary.
  UNIT = ->(n) { (n - 1).i }.freeze
  # Constant for real unit.
  R = UNIT[1]
  # Constant for imaginary unit.
  I = UNIT[2]

  # @return [Integer]
  attr_reader :size
  # @return [Hash{Symbol => Object}]
  attr_reader :options

  # Create new VectorNumber from +values+.
  #
  # @example
  #   VectorNumber[1, 2, 3] #=> (6)
  #   VectorNumber[[1, 2, 3]] #=> (1⋅[1, 2, 3])
  #   VectorNumber['b', VectorNumber::I, mult: :asterisk] #=> (1*'b' + 1i)
  # @param values [Array<Object>] values to put in the number
  # @param options [Hash{Symbol => Object}] options for the number
  # @return [VectorNumber]
  def self.[](*values, **options)
    new(values, options)
  end

  # @param values [Array, Hash{Object => Integer, Float, Rational, BigDecimal}, VectorNumber]
  #   values for this number, hashes are treated like plain vector numbers
  # @param options [Hash{Symbol => Object}]
  #   if +values+ is a VectorNumber, this argument is ignored
  #   and +options+ are copied directly from +values+
  # @option options [Symbol, String] :mult
  #   text to use between unit and coefficient, see {Stringifying#to_s} for explanation
  # @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
  # @yieldreturn [Integer, Float, Rational, BigDecimal] new coefficient
  # @raise [RangeError] if any pesky non-reals get where they shouldn't
  def initialize(values = nil, options = {}, &)
    super()
    initialize_from(values)
    apply_transform(&)
    finalize_contents
    values.is_a?(VectorNumber) ? save_options(values.options, safe: true) : save_options(options)
    @data.freeze
    freeze
  end

  private

  NONE = Object.new
  private_constant :NONE

  # Create new VectorNumber from a value or self, optionally applying a transform.
  # @param from [Object] self if not specified
  # @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
  # @yieldreturn [Integer, Float, Rational, BigDecimal] new coefficient
  # @return [VectorNumber]
  def new(from = NONE, &)
    from = self if from == NONE
    self.class.new(from, &)
  end

  def default_options
    DEFAULT_OPTIONS
  end

  def known_options
    KNOWN_OPTIONS
  end

  # @param value [Object]
  # @return [Boolean]
  def real_number?(value)
    (value.is_a?(Numeric) && value.real?) || (value.is_a?(self.class) && value.numeric?(1))
  end
end
