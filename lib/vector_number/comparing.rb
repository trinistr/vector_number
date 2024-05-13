# frozen_string_literal: true

class VectorNumber
  # Methods for comparing with other numbers.
  module Comparing
    # @param other [Object]
    # @return [Boolean]
    def eql?(other)
      return true if equal?(other)

      if other.is_a?(self.class)
        other.size == size && other.data == @data
      else
        false
      end
    end
  end
end
