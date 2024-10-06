# frozen_string_literal: true

bigdecimal_supported = true
unless defined?(BigDecimal)
  begin
    require "bigdecimal"
  rescue LoadError
    bigdecimal_supported = false
  end
end

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

  config.formatter =
    if config.files_to_run.size > 1
      :progress
    else
      :documentation
    end

  # Include `#num` method in specs for easy generation of VectorNumbers.
  number_helper =
    Module.new do
      def num(...)
        VectorNumber.[](...)
      end
    end
  config.include number_helper

  # Skip tests using BigDecimal if no support is available.
  unless bigdecimal_supported
    config.filter_run_excluding(bigdecimal: true)
    warn "no BigDecimal support detected, BigDecimal tests will not be run"
  end
end
