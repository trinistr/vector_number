# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# For running checks
gem "rake", "~> 13.0", require: false

# Testing
gem "rspec", "~> 3.0", require: false

group :linting do
  # Linting
  gem "rubocop", "~> 1.72", require: false
  gem "rubocop-packaging", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-thread_safety", require: false
  gem "rubocop-yard", require: false

  # Checking type signatures
  gem "rbs", require: false
end

group :optional do
  # Development and testing use BigDecimal, though it is not required for the gem.
  gem "bigdecimal"
end

group :development do
  # Type checking
  gem "steep", require: false

  # Code coverage report
  gem "simplecov", require: false

  # Documentation
  gem "yard", require: false

  # Language server for development
  gem "solargraph", require: false

  # Version changes
  gem "bump", require: false
end
