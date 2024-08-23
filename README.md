# VectorNumber

![validation workflow](https://github.com/trinistr/vector_number/actions/workflows/validation.yml/badge.svg)

A library to add together anything: be it a number, string or random Object, it can be added together in an infinite-dimensional vector space, with math operations available on results.

This is similar in a sense to hypercomplex numbers, such as quaternions, but with a focus on arbitrary dimensions.

Similar projects:
- [vector_space](https://github.com/tomstuart/vector_space) aims to provide typed vector spaces with limited dimensions and nice formatting.
- [named_vector](https://rubygems.org/gems/named_vector) provides simple vectors with named dimensions.
- Various quaternion libraries.

## Installation

Add gem to your Gemfile:
```ruby
gem "vector_number", git: "https://github.com/trinistr/vector_number.git"
```
Installation through `gem` is not currently supported.

## Usage

Usage is pretty simple and intuitive:
```ruby
require "vector_number"
VectorNumber[5] + VectorNumber["string"] - 0.5 # => (4.5 + 1⋅'string')
VectorNumber["string", "string", "string", "str"] # => (3⋅'string' + 1⋅'str')
VectorNumber[:s] * 2 + VectorNumber["string"] * 0.3 # => (2⋅s + 0.3⋅'string')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests, `rake rubocop` to check code, `rake steep` to check typing or just `rake` to do everything. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, change Next version in `CHANGELOG.md`, commit changes and tag the commit.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/trinistr/vector_number.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
