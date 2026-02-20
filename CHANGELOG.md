# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Next]

**Added**
- "Hash mode" to `VectorNumber.[]`, allowing to quickly create VectorNumbers with desired coefficients.
  - Using positional arguments and keyword arguments together is prohibited.
- `#ceildiv` method, inspired by `Integer#ceildiv`. Works similarly to `#div`, but rounds up instead of down.
- A host of binary vector operations:
  - `#dot_product` (aliased as `#inner_product` and `#scalar_product`)
  - `#cross_product` (aliased as `#vector_product`)
  - `#angle`
  - `#orthogonal?`, `#collinear?`, `#parallel?`, `#codirectional?`, `#opposite?`
  - `#scalar_projection`, `#vector_projection`
  - `#scalar_rejection`, `#vector_rejection`
- Some utility methods related to linear subspaces:
  - `#subspace_basis`, `#subspace_projections`
  - `#uniform_vector`
  - `#unit_vector`
- Methods for calculating norms:
  - `#p_norm`
  - `#maximum_norm` (aliased as `#infinity_norm`)
  - 2-norm (Euclidean norm) can already be calculated using `#magnitude`.
- Methods for calculating similarity measures:
  - `#cosine_similarity`
  - `#jaccard_index`
  - `#jaccard_similarity`
- Multiple hash-like methods:
  - `#coefficients_at` (aliased as `#values_at`)
  - `#assoc`
  - `#dig`
  - `#fetch`
  - `#fetch_coefficients` (aliased as `#fetch_values`)
  - `#transform_coefficients` (aliased as `#transform_values`)
  - `#transform_units` (aliased as `#transform_keys`)
- `#pretty_print` method to support `PP` which works much in the same way as `#inspect`. This is mainly useful in interactive sessions.

**Changed**
- [🍄 BREAKING] `#to_s` and `#inspect` now call `#inspect` on all coefficients and non-special units, better aligning with standard classes.
  - Neither Strings nor Symbols are displayed completely unadorned now.
  - Rational coefficients are displayed in extra brackets.
- `#abs` is now an alias of `#magnitude`, instead of the other way around.
- `VectorNumber.[]` now raises `ArgumentError` if a block is passed. Previously, block was silently ignored.
- Incorrectly using numeric keys when initializing from a hash now raises `RangeError`.
- Internal changes now (hopefully) allow for full support for `BasicObject` objects, though some methods are required.
  - `#hash` and `#eql?` are always required.
  - `#inspect` is required for stringification.
- `SpecialUnit` class is now considered public API. Users may create new instances of it for their own use.

[Compare v0.6.1...main](https://github.com/trinistr/vector_number/compare/v0.6.1...main)

## [v0.6.1] — 2026-02-08

This version removes the image file added to the gem in version 0.6.0. It was not displayed on RubyDoc.info and bloated the gem.

[Compare v0.6.0...v0.6.1](https://github.com/trinistr/vector_number/compare/v0.6.0...v0.6.1)

## [v0.6.0] — 2026-01-31

In this update, stringification of VectorNumbers has been streamlined. It is both more powerful and more efficient.

**Added**
- Block parameter in `#to_s`, allowing to customize string conversion.
- `VectorNumber::SpecialUnit` class for representing special numerical units. It mostly exists to provide its `#to_s` method.
  - [🍄 BREAKING] `R` and `I` constants are now instances of `SpecialUnit` class.
- `.numeric_unit?` method and `NUMERIC_UNITS` constant for checking units.

**Removed**
- [🍄 BREAKING] Removed options in their entirety. The only way to specify multiplication symbol is in call to `#to_s`.
  - Constructors' signatures now include `**nil` to prevent mistakes.
- `UNIT` constant. Use `NUMERIC_UNITS` instead (though you shouldn't anyway).

**Changed**
- `VectorNumber#to_s` now calls `#inspect` on Strings instead of just using `String#to_s`. This prevents issues with embedded quotation marks.
  - As a a side effect, String units are now surrounded by double quotes, not single.

[Compare v0.5.0...v0.6.0](https://github.com/trinistr/vector_number/compare/v0.5.0...v0.6.0)

## [v0.5.0] — 2026-01-23

This update changes code structure, aligning it more closely with the intended design, and improves documentation.

**Changed**
- [🍄 BREAKING] Remove inner modules. All methods are now defined directly on `VectorNumber`. This was always the intended public interface.
- Update documentation. Add a listing of all methods and general information to class's documentation. Group methods by type.

**Fixed**
- `#eql?` now correctly tests equality using `eql?`, not `==`. `v1.eql?(v2) -> v1.hash == v2.hash` should now always hold.

[Compare v0.4.3...v0.5.0](https://github.com/trinistr/vector_number/compare/v0.4.3...v0.5.0)

## [v0.4.3] — 2025-10-08

**Changed**
- Decrease minimum required Ruby version to 3.0.0. "vector_number/numeric_refinements" will not work on 3.0, however.

[Compare v0.4.2...v0.4.3](https://github.com/trinistr/vector_number/compare/v0.4.2...v0.4.3)

## [v0.4.2] — 2025-10-08

This update improves gem's description and README in an effort to make it clearer what the gem does.

**Added**
- Add description and a better summary to gemspec.
- Add overview of main features to README.
- Add `#hash` method to properly support VectorNumbers as Hash keys.

[Compare v0.4.1...v0.4.2](https://github.com/trinistr/vector_number/compare/v0.4.1...v0.4.2)

## [v0.4.1] — 2025-07-07

Small update to fix Changelog.

[Compare v0.4.0...v0.4.1](https://github.com/trinistr/vector_number/compare/v0.4.0...v0.4.1)

## [v0.4.0] — 2025-07-07

This update significantly speeds up creation of VectorNumbers.

**Changed**
- [🍄 BREAKING] Change `R` and `I` constants to be `1` and `2` instead of `0i` and `1i` respectively. Their values are still semi-private and should not be relied on.
- [🍄 BREAKING] Calling `new` with an unsupported value now raises `ArgumentError` instead of treating it like air.
- Optimize various initialization paths. It is now 1.5–2.5 times faster, depending on arguments.
- [🚀 CI] Disable JRuby testing on CI. There were too many issues with JRuby, and it's not a priority to support it.

[Compare v0.3.1...v0.4.0](https://github.com/trinistr/vector_number/compare/v0.3.1...v0.4.0)

## [v0.3.1] — 2025-06-21

This is mostly a documentation update with a side of improved gemspec.

**Changed**
- Improve method documentation and unify documentation style across the board.
- Improve gemspec:
  - change source code and changelog links to point to a tagged commit;
  - add links to bugtracker and documentation (for appropriate version);
  - properly add CHANGELOG.md to doc generation.
- Improve documentation for NumericRefinements to include examples and more info.
- `#+@` is now a trivial method, not an alias.
  - `#dup` is now an alias of `#+@`.
- `#abs` is now calculated from `#abs2` instead of the other way around to reduce errors.

**Fixed**
- Correct broken changelog link in gem metadata.

[Compare v0.3.0...v0.3.1](https://github.com/trinistr/vector_number/compare/v0.3.0...v0.3.1)

## [v0.3.0] — 2025-05-12

**Added**
- Add aliases to other operators: `#neg` for `#-@`, `#add` for `#+`, `#sub` for `#-`, `#mult` for `#*`. `#+@` was already practically aliased by `#dup`.

**Changed**
- [🍄 BREAKING] Long-existing but broken options feature is now fixed. When creating new vector through any operation, participating vector's options are copied to the new one. When several vectors are present, only first one matters.
- Both `#+@` and `#dup` are now aliases of `#itself` instead of full methods.
- [🚀 CI] "CI" workflow now reports status of all checks, excluding allowed-to-fail workflows (currently JRuby and TruffleRuby). In the future this will provide more guarantees about gem' quality and compatibility.

[Compare v0.2.6...v0.3.0](https://github.com/trinistr/vector_number/compare/v0.2.6...v0.3.0)

## [v0.2.6] — 2025-04-30

**Added**
- Add `#div`, `#%` (aliased as `#modulo`), `#divmod` and `#remainder` methods.
- Add `#quo` alias to `#/`.

**Fixed**
- `#/`, `#fdiv` as well as new division methods now properly check for division by zero. VectorNumber does not support this as not all Numeric classes do.

**Changed**
- [🚀 CI] Add Ruby 3.4 to CI as ruby-head is now preview of 3.5.

[Compare v0.2.5...v0.2.6](https://github.com/trinistr/vector_number/compare/v0.2.5...v0.2.6)

## [v0.2.5] — 2025-02-26

Technical update after release to rubygems.org.
README was updated to reflect this change.

[Compare v0.2.4...v0.2.5](https://github.com/trinistr/vector_number/compare/v0.2.4...v0.2.5)

## [v0.2.4] — 2025-02-26

**Added**
- Add hash-like methods `#[]` and `#unit?` (aliased as `#key?`).

**Changed**
- [🍄 BREAKING] Change `positive?` and `negative?` to no longer return `nil` when number is neither strictly positive or negative, these cases will now return `false`.
- Make `VectorNumber.new` accept options when initializing from a VectorNumber instead of only copying. Options will be merged.
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

**Removed**
- Remove `#to_str`, as VectorNumber is not a String-like object.
  - Due to this, `Kernel.BigDecimal` no longer works without refinements.

**Changed**
- Allow to use fully real VectorNumbers as real numbers.

**Fixed**
- Fix reversed result in refined `#<=>`.

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
[v0.6.1]: https://github.com/trinistr/vector_number/tree/v0.6.1
[v0.6.0]: https://github.com/trinistr/vector_number/tree/v0.6.0
[v0.5.0]: https://github.com/trinistr/vector_number/tree/v0.5.0
[v0.4.3]: https://github.com/trinistr/vector_number/tree/v0.4.3
[v0.4.2]: https://github.com/trinistr/vector_number/tree/v0.4.2
[v0.4.1]: https://github.com/trinistr/vector_number/tree/v0.4.1
[v0.4.0]: https://github.com/trinistr/vector_number/tree/v0.4.0
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
