# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# For running all checks together
gem "rake", "~> 13.0", require: false

# Testing
gem "rspec", "~> 3.0", require: false

# Linting
gem "rubocop", "~> 1.21", require: false
gem "rubocop-performance", require: false
gem "rubocop-rake", require: false
gem "rubocop-rspec", require: false
gem "rubocop-thread_safety", require: false

# Checking type signatures
gem "rbs", require: false

group :development do
  # Type checking
  gem "steep", require: false

  # Documentation
  gem "yard", require: false

  # Language server for development
  gem "solargraph", require: false

  # Version changes
  gem "bump", require: false
end
