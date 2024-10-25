# frozen_string_literal: true

begin
  require "bigdecimal"
rescue LoadError
  # Ok, either there is no bigdecimal, or it is always available.
end

require_relative "support/coverage_helper"

require "vector_number"

require_relative "support/shared_examples"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random

  config.formatter = (config.files_to_run.size > 1) ? :progress : :documentation

  # Include `#num` method in specs for easy generation of VectorNumbers.
  number_helper =
    Module.new do
      def num(...)
        VectorNumber.[](...)
      end
    end
  config.include number_helper

  # Skip tests using BigDecimal if no support is available.
  config.before(:context, :bigdecimal) do
    skip "BigDecimal is not defined, test will not be run" unless defined?(BigDecimal)
  end
end
