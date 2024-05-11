# frozen_string_literal: true

class VectorNumber < Numeric
  # Methods for comparing with other numbers.
  module Comparing
    # @param other [Object]
    # @return [Boolean]
    def eql?(other)
      return true if equal?(other)
      return false unless other.class == self.class

      other.size == size && other.data == @data
    end
  end
end
