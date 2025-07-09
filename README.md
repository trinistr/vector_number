# VectorNumber

[![Gem Version](https://badge.fury.io/rb/vector_number.svg?icon=si%3Arubygems)](https://rubygems.org/gems/vector_number)
[![CI](https://github.com/trinistr/vector_number/actions/workflows/CI.yaml/badge.svg)](https://github.com/trinistr/vector_number/actions/workflows/CI.yaml)

> [!TIP]
> You may be viewing documentation for an older (or newer) version of the gem. Check badges above to see what the latest released version is, or, better yet, look at [Changelog](https://github.com/trinistr/vector_number/blob/main/CHANGELOG.md) to see all versions, including unreleased changes!

***

VectorNumber is a Ruby gem that provides a Numeric-like experience for doing arithmetics on heterogeneous objects, with more advanced operations based on real vector spaces available when needed.

Features:
- [Add and subtract](#basics) (almost) any object, with no setup or declaration.
- [Multiply and divide](#basics) vectors by any real number to create 1.35 of an array and -2 of a string. What does that mean? Only you know!
- [Use vectors instead of inbuilt numbers](#numerical-behavior) in most situtations with no difference in behavior. Or, use familiar methods from numerics with the same semantics!
- [Enumerate vectors in a hash-like fashion](#enumeration-and-hash-like-behavior), or transform to an array or hash as needed.
- Enjoy a mix of vector-, complex- and polynomial-like behavior at appropriate times.
- No dependencies, no extensions. It just works!

Similar projects:
- [vector_space](https://github.com/tomstuart/vector_space) aims to provide typed vector spaces with limited dimensions and nice formatting;
- [named_vector](https://rubygems.org/gems/named_vector) provides simple vectors with named dimensions;
- various quaternion libraries like [quaternion](https://github.com/tanahiro/quaternion) or [rmath3d](https://github.com/vaiorabbit/rmath3d).

However, none of them have been updated in *years*.

## Installation

Install with `gem`:
```sh
gem install vector_number
```

If using Bundler, add gem to your Gemfile:
```ruby
gem "vector_number"
```

## Usage

### Basics

VectorNumbers are mostly useful for tallying up heterogeneous objects:
```ruby
sum = [4, "death", "death", 13, nil].reduce(VectorNumber[], :+)
sum # => (17 + 2⋅'death' + 1⋅)
sum.to_h # => {1=>17, "death"=>2, nil=>1}
sum.to_a # => [[1, 17], ["death", 2], [nil, 1]]

# Alternatively, the same result can be equivalently (and more efficiently)
# achieved by passing all values to a constructor:
VectorNumber[4, "death", "death", 13, nil]
VectorNumber.new([4, "death", "death", 13, nil])
```

Doing arithmetic with vectors is simple and intuitive:
```ruby
VectorNumber["string"] + "string" # => (2⋅'string')
VectorNumber["string"] - "str" # => (1⋅'string' - 1⋅'str')
VectorNumber[5] + VectorNumber["string"] - 0.5 # => (4.5 + 1⋅'string')
VectorNumber["string", "string", "string", "str"] # => (3⋅'string' + 1⋅'str')
# Multiply and divide by any real number:
VectorNumber[:s] * 2 + VectorNumber["string"] * 0.3 # => (2⋅s + 0.3⋅'string')
VectorNumber[:s] / VectorNumber[3] # => (1/3⋅s)
# Multiplication even works when the left operand is a regular number:
1/3r * VectorNumber[[]] # => (1/3⋅[])
```

### (Somewhat) advanced usage

> [!TIP]
> Look at [API documentation](https://rubydoc.info/gems/vector_number) for all methods.

#### Frozenness
VectorNumbers are always frozen, as a number should be. However, they hold references to units (keys), which aren't frozen or duplicated. It is the user's responsibility to ensure that keys aren't mutated, the same as it is for Hash.

As vectors are immutable, `+@`, `dup` and `clone` return the same instance.

#### Numerical behavior
VectorNumbers implement most of the methods you can find in `Numeric`, with appropriate behavior. For example:
- `abs` (`magnitude`) calculates length of the vector;
- `infinite?` checks whether any coefficient is infinite (or NaN), in the same way as `Complex` does it;
- `positive?` is true if all coefficients are positive, the same for `negative?` (though this is different from `Complex`);
- `round` and friends round each coefficient, with all the bells and whistles;
- `div` and `%` perform division and remainder operations elementwise;
- `5 < VectorNumber[6]` returns `true` and `5 < VectorNumber["string"]` returns `nil`, etc.

VectorNumbers, if only consisting of a real number, can mostly be used interchangeably with core numbers due to `coerce` and conversion (`to_i`, etc.) methods. They can even be used as array indices! Due to including `Comparable`, they can also participate in comparison and sorting.

#### Enumeration and Hash-like behavior
VectorNumbers implement `each` (`each_pair`) in the same way as Hash does, allowing `Enumerable` methods to be used in a familiar way.

There are also the usual `[]`, `unit?` (`key?`), `units` (`keys`), `coefficients` (`values`) methods. `to_h` and `to_a` can be used if a regular Hash or Array is needed.

> [!NOTE]
> Be aware that `[]` always returns `0` for "missing" units. `unit?` will return `false` for them.

## Ruby engine support status

VectorNumber is developed on MRI (CRuby) but should work on other engines too.
- TruffleRuby: there are some minor differences in behavior, but otherwise works as expected.
- JRuby: significant problems, but may work, currently not tested.
- Other engines: untested, but should work, depending on compatibility with MRI.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests, `rake rubocop` to lint code and check style compliance, `rake rbs` to validate signatures or just `rake` to do everything above. There is also `rake steep` to check typing, and `rake docs` to generate YARD documentation.

You can also run `bin/console` for an interactive prompt that will allow you to experiment, or `bin/benchmark` to run a benchmark script and generate a StackProf flamegraph.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, run `bundle exec rake version:{major|minor|patch}`, and then run `bundle exec rake release`, which will push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/trinistr/vector_number]().

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
