# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Next]

**Added**
- Add `#div`, `#%` (aliased as `#modulo`), `#divmod` and `#remainder` methods.
- Add `#quo` alias to `#/`.

**Fixed**
- `#/`, `#fdiv` as well as new division methods now properly check for division by zero.
   VectorNumber does not support this as not all Numeric classes do.

## [v0.2.5] — 2025-02-26

Technical update after release to rubygems.org.
README was updated to reflect this change.

## [v0.2.4] — 2025-02-26

**Added**
- Add hash-like methods `#[]` and `#unit?` (aliased as `#key?`).

**Changed**
- [Breaking] Change `positive?` and `negative?` to no longer return `nil`,
   those cases will now return `false`.
- Make `VectorNumber.new` accept options when initializing from a VectorNumber
   instead of only copying. Options will be merged.
- Remove `Initializing` module, move its methods to the actual class.
- Update development gems' versions.

**Fixed**
- `#dup` and `#clone` now behave exactly like Numeric versions, preventing unfreezing.

## [v0.2.3] — 2024-10-15

**Fixed**
- BigDecimal tests are now properly skipped when BigDecimal is not available, instead of always.

## [v0.2.2] — 2024-10-07

**Added**
- Add `#abs` (aliased as `#magnitude`) and `#abs2`.
- Add `#ceil`, `#floor` and `#round`.

**Changed**
- Add ruby 3.1.0, covering the earliest supported version, and ruby-next (3.4) to CI.
- Add JRuby and TruffleRuby to CI, without full support.
- Make tests runnable even without available `bigdecimal` gem.

**Fixed**
- `Kernel#BigDecimal` refinement now correctly works without `ndigits` argument.

## [v0.2.1] — 2024-08-24

**Added**
- Add back `#*` and `#/` for working with real numbers.
- Add `#fdiv`, `#truncate`, `#nonnumeric?` and `#integer?`.

**Changed**
- Allow to use fully real VectorNumbers as real numbers.

**Fixed**
- Fix reversed result in refined `#<=>`.

**Removed**
- Remove `#to_str`, as VectorNumber is not a String-like object.
- Due to the above, `Kernel.BigDecimal` no longer works without refinements.

## [v0.2.0] — 2024-08-19

**Added**
- VectorNumbers can be created from any object or collection.
- Addition and subtraction are supported.
- VectorNumbers are mostly interoperable with core numbers.

## [v0.1.0] — 2024-05-09

- Initial work.
