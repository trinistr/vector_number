# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Next]

**Changed**
- [🍄 BREAKING] Change `R` and `I` constants to be `1` and `2` instead of `0i` and `1i` respectively.
   Their values are still semi-private and should not be relied on.
- [🍄 BREAKING] Calling `new` with an unsupported value now raises `ArgumentError` instead of treating it like air.
- Optimize various initialization paths. It is now 1.5-2.5 times faster, depending on arguments.
- [🚀 CI] Disable JRuby testing on CI.

[Compare v0.3.1...main](https://github.com/trinistr/vector_number/compare/v0.3.1...main)

## [v0.3.1] — 2025-06-21

This is mostly a documentation update with a side of improved gemspec.

**Changed**
- Improve method documentation and unify documentation style across the board.
- Improve gemspec:
  - change source code and changelog links to point to a tagged commit;
  - add links to bugtracker and documentation (for appropriate version);
  - properly add CHANGELOG.md to doc generation.
- Improve documentation for NumericRefinements to include examples and more info.
- `#dup` is now an alias of `#+@` with no change in function.
- `#abs` is now calculated from `#abs2` instead of the other way around to reduce errors.

**Fixed**
- Correct broken changelog link in gem metadata.

[Compare v0.3.0...v0.3.1](https://github.com/trinistr/vector_number/compare/v0.3.0...v0.3.1)

## [v0.3.0] — 2025-05-12

**Added**
- Add aliases to other operators:
   `#neg` for `#-@`, `#add` for `#+`, `#sub` for `#-`, `#mult` for `#*`.
   `#+@` was already practically aliased by `#dup`.

**Changed**
- [🍄 BREAKING] Long-existing but broken options feature is now fixed.
   When creating new vector through any operation, participating vector's options
   are copied to the new one. When several vectors are present, only first one matters.
- Both `#+@` and `#dup` are now aliases of `#itself` instead of full methods.
- [🚀 CI] "CI" workflow now reports status of all checks,
   excluding allowed-to-fail workflows (currently JRuby and TruffleRuby).

[Compare v0.2.6...v0.3.0](https://github.com/trinistr/vector_number/compare/v0.2.6...v0.3.0)

## [v0.2.6] — 2025-04-30

**Added**
- Add `#div`, `#%` (aliased as `#modulo`), `#divmod` and `#remainder` methods.
- Add `#quo` alias to `#/`.

**Fixed**
- `#/`, `#fdiv` as well as new division methods now properly check for division by zero.
   VectorNumber does not support this as not all Numeric classes do.

**Changed**
- [🚀 CI] Add Ruby 3.4 to CI.

[Compare v0.2.5...v0.2.6](https://github.com/trinistr/vector_number/compare/v0.2.5...v0.2.6)

## [v0.2.5] — 2025-02-26

Technical update after release to rubygems.org.
README was updated to reflect this change.

[Compare v0.2.4...v0.2.5](https://github.com/trinistr/vector_number/compare/v0.2.4...v0.2.5)

## [v0.2.4] — 2025-02-26

**Added**
- Add hash-like methods `#[]` and `#unit?` (aliased as `#key?`).

**Changed**
- [🍄 BREAKING] Change `positive?` and `negative?` to no longer return `nil`
   when number is neither strictly positive or negative,
   these cases will now return `false`.
- Make `VectorNumber.new` accept options when initializing from a VectorNumber
   instead of only copying. Options will be merged.
- Remove `Initializing` module, move its methods to the actual class.
- Update development gems' versions.

**Fixed**
- `#dup` and `#clone` now behave exactly like Numeric versions, preventing unfreezing.

[Compare v0.2.3...v0.2.4](https://github.com/trinistr/vector_number/compare/v0.2.3...v0.2.4)

## [v0.2.3] — 2024-10-15

**Fixed**
- BigDecimal tests are now properly skipped when BigDecimal is not available, instead of always.

[Compare v0.2.2...v0.2.3](https://github.com/trinistr/vector_number/compare/v0.2.2...v0.2.3)

## [v0.2.2] — 2024-10-07

**Added**
- Add `#abs` (aliased as `#magnitude`) and `#abs2`.
- Add `#ceil`, `#floor` and `#round`.

**Changed**
- [🚀 CI] Add ruby 3.1.0, covering the earliest supported version, and ruby-next (3.4) to CI.
- [🚀 CI] Add JRuby and TruffleRuby to CI, without full support.
- [🚀 CI] Make tests runnable even without available `bigdecimal` gem.

**Fixed**
- `Kernel#BigDecimal` refinement now correctly works without `ndigits` argument.

[Compare v0.2.1...v0.2.2](https://github.com/trinistr/vector_number/compare/v0.2.1...v0.2.2)

## [v0.2.1] — 2024-08-24

**Added**
- Add `#*` and `#/` for working with real numbers.
- Add `#fdiv`, `#truncate`, `#nonnumeric?` and `#integer?`.

**Changed**
- Allow to use fully real VectorNumbers as real numbers.

**Fixed**
- Fix reversed result in refined `#<=>`.

**Removed**
- Remove `#to_str`, as VectorNumber is not a String-like object.
- Due to the above, `Kernel.BigDecimal` no longer works without refinements.

[Compare v0.2.0...v0.2.1](https://github.com/trinistr/vector_number/compare/v0.2.0...v0.2.1)

## [v0.2.0] — 2024-08-19

**Added**
- VectorNumbers can be created from any object or collection.
- Addition and subtraction are supported.
- VectorNumbers are mostly interoperable with core numbers.

[Compare v0.1.0...v0.2.0](https://github.com/trinistr/vector_number/compare/v0.1.0...v0.2.0)

## [v0.1.0] — 2024-05-09

- Initial work.

[Next]: https://github.com/trinistr/vector_number/tree/main
[v0.3.1]: https://github.com/trinistr/vector_number/tree/v0.3.1
[v0.3.0]: https://github.com/trinistr/vector_number/tree/v0.3.0
[v0.2.6]: https://github.com/trinistr/vector_number/tree/v0.2.6
[v0.2.5]: https://github.com/trinistr/vector_number/tree/v0.2.5
[v0.2.4]: https://github.com/trinistr/vector_number/tree/v0.2.4
[v0.2.3]: https://github.com/trinistr/vector_number/tree/v0.2.3
[v0.2.2]: https://github.com/trinistr/vector_number/tree/v0.2.2
[v0.2.1]: https://github.com/trinistr/vector_number/tree/v0.2.1
[v0.2.0]: https://github.com/trinistr/vector_number/tree/v0.2.0
[v0.1.0]: https://github.com/trinistr/vector_number/tree/v0.1.0
[🚀 CI]: https://github.com/trinistr/vector_number/actions/workflows/CI.yaml
