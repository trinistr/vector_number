# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Next]
- Remove `#to_str`, as VectorNumber is not a String-like object.
- Due to the above, `Kernel.BigDecimal` no longer works without refinements.

## [v0.2.0] — 2024-08-19
- VectorNumbers can be created from any object or collection.
- Addition and subtraction are supported.
- VectorNumbers are mostly interoperable with core numbers.

## [v0.1.0] — 2024-05-09
- Initial work.
