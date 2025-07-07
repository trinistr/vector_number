# VectorNumber

> [!TIP]
> You may be viewing documentation for an older (or newer) version of the gem.
> Check badges below to see what the latest released version is.
> Look at [Changelog](https://github.com/trinistr/vector_number/blob/main/CHANGELOG.md)
> to see all versions, including unreleased changes!

Latest: [![Gem Version](https://badge.fury.io/rb/vector_number.svg?icon=si%3Arubygems)](https://rubygems.org/gems/vector_number)
[![CI](https://github.com/trinistr/vector_number/actions/workflows/CI.yaml/badge.svg)](https://github.com/trinistr/vector_number/actions/workflows/CI.yaml)

***

A library to add together anything: be it a number, string or random Object, it can be added together with math operations available on results in a real vector space, though some operations are modeled on hypercomplex numbers.

Similar projects:
- [vector_space](https://github.com/tomstuart/vector_space) aims to provide typed vector spaces with limited dimensions and nice formatting;
- [named_vector](https://rubygems.org/gems/named_vector) provides simple vectors with named dimensions;
- various quaternion libraries like [quaternion](https://github.com/tanahiro/quaternion) or [rmath3d](https://github.com/vaiorabbit/rmath3d).

However, none of them have been updated in *years*.

## Installation

VectorNumber does not have any dependencies and does not include extensions.

Install with `gem` (available from [0.2.4](https://github.com/trinistr/vector_number/tree/v0.2.4)):
```sh
gem install vector_number
```

If using Bundler, add gem to your Gemfile:
```ruby
gem "vector_number"
```

## Usage

Usage is pretty simple and intuitive:
```ruby
require "vector_number"
VectorNumber["string"] + "str" # => (1⋅'string' + 1⋅'str')
VectorNumber[5] + VectorNumber["string"] - 0.5 # => (4.5 + 1⋅'string')
VectorNumber["string", "string", "string", "str"] # => (3⋅'string' + 1⋅'str')
VectorNumber[:s] * 2 + VectorNumber["string"] * 0.3 # => (2⋅s + 0.3⋅'string')
VectorNumber[:s] / 3 # => (1/3⋅s)
1/3r * VectorNumber[[]] # => (1/3⋅[])
```

VectorNumbers are mostly useful for summing up heterogeneous objects:
```ruby
sum = VectorNumber[]
[4, "death", "death", 13, nil].each { sum = sum + _1 }
sum # => (17 + 2⋅'death' + 1⋅)
sum.to_a # => [[1, 17], ["death", 2], [nil, 1]]
sum.to_h # => {1=>17, "death"=>2, nil=>1}
```

Alternatively, the same result can be equivalently (and more efficiently) achieved by passing all values to a constructor:
```ruby
VectorNumber[4, "death", "death", 13, nil]
VectorNumber.new([4, "death", "death", 13, nil])
```

## Ruby engine support status

VectorNumber is developed on MRI (CRuby) but should work on other engines too.
- TruffleRuby: works as expected, but there are differences in core Ruby code, so some tests fail.
- JRuby: significant problems, but may work, currently not tested.
- Other engines: untested, but should work, depending on compatibility.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests, `rake rubocop` to lint code and check style compliance, `rake rbs` to validate signatures or just `rake` to do everything above. There is also `rake steep` to check typing, and `rake docs` to generate YARD documentation.

You can also run `bin/console` for an interactive prompt that will allow you to experiment, or `bin/benchmark` to run a benchmark script and generate a StackProf flamegraph.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, run `bundle exec rake version:{major|minor|patch}`, and then run `bundle exec rake release`, which will push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/trinistr/vector_number]().

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
