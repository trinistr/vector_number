# frozen_string_literal: true

require_relative "vector_number/version"
require_relative "vector_number/initializing"
require_relative "vector_number/comparing"
require_relative "vector_number/querying"

# A class to add together anything.
class VectorNumber < Numeric
  include Enumerable

  include Initializing
  include Comparing
  include Querying

  # @return [Complex]
  I = 1.i

  attr_reader :size
  # @return [Hash{Symbol => Object}]
  attr_reader :options

  # @param values [Array<Object>] values to put in the number
  # @param options [Hash{Symbol => Object}] options for the number
  # @return [VectorNumber]
  def self.[](*values, **options)
    new(values, options)
  end

  # @param values [Array, Hash{Object => Numeric}, VectorNumber]
  #   values for this number, hashes are treated like plain vector numbers
  # @param options [Hash{Symbol => Object}]
  #   ignored if +values+ is a VectorNumber
  # @yieldparam coefficient [Numeric]
  # @yieldreturn [Numeric] new coefficient, must be a real number
  # @raise [RangeError] if any pesky non-reals get where they shouldn't
  def initialize(values = nil, options = {}, &)
    super()
    initialize_from(values)
    apply_transform(&) if block_given?
    finalize_contents
    values.is_a?(self.class) ? save_options(values.options, safe: true) : save_options(options)
    @data.freeze
    freeze
  end

  def each
    return to_enum(__method__, size) unless block_given?

    @data.each { |unit, value| yield [unit, value] if value.nonzero? }
  end

  alias each_pair each

  protected

  # @return [Hash{Object => Numeric}]
  attr_reader :data

  # @return [Symbol]
  def type_of_self
    :vector
  end

  private

  # @param value [Object]
  # @return [Symbol]
  def type_of(value)
    case value
    when self.class
      value.type_of_self
    when Complex
      value.imaginary.nonzero? ? :complex : :real
    when Numeric
      value.real? ? :real : :itself
    else
      :itself
    end
  end
end
