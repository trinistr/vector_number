# frozen_string_literal: true

require_relative "vector_number/version"
require_relative "vector_number/vector"

# A library to add together anything.
module VectorNumber
  class Error < StandardError; end

  def self.[](*args)
    Vector.new(args)
  end
end
