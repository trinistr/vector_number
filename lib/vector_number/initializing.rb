# frozen_string_literal: true

class VectorNumber
  # Private methods for initializing vector numbers.
  module Initializing
    private

    # @param values [Array, Hash{Object => Integer, Float, Rational, BigDecimal}, VectorNumber, nil]
    # @return [void]
    def initialize_from(values)
      initialize_data

      case values
      when VectorNumber, Hash
        add_vector_to_data(values)
      when Array
        values.each { |value| add_value_to_data(value) }
      else
        # Don't add anything.
      end
    end

    # Create +@data+.
    # @return [void]
    def initialize_data
      @data = Hash.new(0)
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
      @data[I] += value.imaginary
    end

    # @param vector [VectorNumber, Hash{Object => Integer, Float, Rational, BigDecimal}]
    # @return [void]
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
    def save_options(options, values:)
      @options =
        case [options, values]
        in Hash, VectorNumber if options.empty?
          values.options
        in Hash, VectorNumber unless options.empty?
          values.options.merge(options).slice(*known_options)
        in Hash, _ unless options.empty?
          default_options.merge(options).slice(*known_options)
        else
          default_options
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
end
