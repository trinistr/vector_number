# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Next]
**Fixed**
- BigDecimal tests are now properly skipped when BigDecimal is not available, instead of always.

## [v0.2.2] — 2024-10-07
**Added**
- Add `#abs` (aliased as `#magnitude`) and `#abs2`.
- Add `#ceil`, `#floor` and `#round`.

**Changed**
- CI now also runs on ruby 3.1.0, the earliest supported version, and ruby-next (3.4).
- CI now also runs for JRuby and TruffleRuby.
- Tests can now be run even without available `bigdecimal` gem.

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
