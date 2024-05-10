# frozen_string_literal: true

require_relative "vector_number/version"
require_relative "vector_number/querying"

# A class to add together anything.
class VectorNumber < Numeric
  include Enumerable

  class Error < StandardError; end

  I = 1.i

  def self.[](*args)
    new(args)
  end

  def initialize(array = nil)
    super()
    @data = Hash.new(0)
    array&.each { |value| put_value_in_buckets(value) }
  end

  def size
    @data.size
  end

  def each
    return to_enum(__method__, size) unless block_given?

    @data.each { |unit, value| yield [unit, value] if value.nonzero? }
  end

  alias each_pair each

  protected

  attr_reader :data

  def data=(hash)
    @data = hash.dup
  end

  def add_vector_to_self(vector)
    vector.each { |unit, value| @data[unit] += value }
  end

  def type_of_self
    :vector
  end

  private

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

  def put_value_in_buckets(value)
    case type_of(value)
    when :complex, :real
      put_numeric_value_in_buckets(value)
    when :vector
      add_vector_to_self(value)
    when :itself
      @data[value] += 1
    end
  end

  def put_numeric_value_in_buckets(value)
    @data[1] += value.real
    @data[I] += value.imaginary
  end
end
