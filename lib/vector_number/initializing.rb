# frozen_string_literal: true

class VectorNumber < Numeric
  # Private methods for initializing vector numbers.
  module Initializing
    # @return [Array<Symbol>]
    KNOWN_OPTIONS = %i[mult].freeze

    # @return [Hash{Symbol => Object}]
    DEFAULT_OPTIONS = {
      mult: :dot
    }.freeze

    private

    # @param values [Array, Hash{Object => Integer, Float, Rational, BigDecimal}, VectorNumber, nil]
    # @return [void]
    def initialize_from(values)
      initialize_contents unless values.is_a?(self.class)

      case values
      when self.class
        @data = values.data.dup
      when Hash
        add_vector_to_data(values)
      when Array
        values&.each { |value| add_value_to_data(value) }
      end
    end

    # Create +@data+.
    # @return [void]
    def initialize_contents
      @data = Hash.new(0)
    end

    # @param value [VectorNumber, Numeric, Object]
    # @return [void]
    def add_value_to_data(value)
      case type_of(value)
      when :complex, :real
        add_numeric_value_to_data(value)
      when :vector
        add_vector_to_data(value)
      when :itself
        @data[value] += 1
      end
    end

    # @param value [Numeric]
    # @return [void]
    def add_numeric_value_to_data(value)
      @data[1] += value.real
      @data[I] += value.imaginary
    end

    # @param vector [VectorNumber, Hash{Object => Integer, Float, Rational, BigDecimal}]
    # @return [void]
    def add_vector_to_data(vector)
      vector.each do |unit, coefficient|
        raise RangeError, "#{coefficient} is not a real number" unless real_number?(coefficient)

        @data[unit] += coefficient
      end
    end

    # @yieldparam coefficient [Integer, Float, Rational, BigDecimal]
    # @yieldreturn [Integer, Float, Rational, BigDecimal]
    # @return [void]
    # @raise [RangeError]
    def apply_transform(&block)
      return unless block

      @data.transform_values! do |coefficient|
        new_value = block[coefficient]
        next new_value if real_number?(new_value)

        raise RangeError, "transform returned non-real value"
      end
    end

    # @param options [Hash{Symbol => Object}, nil]
    # @param safe [Boolean] whether options come from another instance of this class
    # @return [void]
    def save_options(options, safe: false)
      @options =
        if safe
          options
        elsif options.is_a?(Hash)
          DEFAULT_OPTIONS.merge(options.slice(*KNOWN_OPTIONS)).freeze
        else
          DEFAULT_OPTIONS
        end
    end

    # Compact coefficients, calculate size and freeze data.
    # @return [void]
    def finalize_contents
      @data.delete_if { |_u, c| c.zero? }
      @data.freeze
      @size = @data.size
    end

    # @param value [Object]
    # @return [Boolean]
    def real_number?(value)
      value.is_a?(Numeric) && value.real?
    end
  end
end
