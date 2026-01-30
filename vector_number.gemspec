# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "vector_number"
  spec.version = File.read("lib/#{spec.name}/version.rb")[/(?<=VERSION = ")[\d.]+/]
  spec.authors = ["Alexander Bulancov"]

  spec.homepage = "https://github.com/trinistr/#{spec.name}"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"
  spec.summary = "Add, subtract and do math with any objects"
  spec.description = <<~TEXT
    VectorNumber provides a Numeric-like experience for doing arithmetics on heterogeneous objects, with more advanced operations based on real vector spaces available when needed.

    Features:
    - Add and subtract (almost) any object, with no setup or declaration.
    - Multiply and divide vectors by any real number to create 1.35 of an array and -2 of a string. What does that mean? Only you know!
    - Use vectors instead of inbuilt numbers in most situtations with no difference in behavior. Or, use familiar methods from numerics with sane semantics!
    - Enumerate vectors in a hash-like fashion, or transform to an array or hash as needed.
    - Enjoy a mix of vector-, complex- and polynomial-like behavior at appropriate times.
    - No dependencies, no extensions. It just works!
  TEXT

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{lib,sig,exe}/**/*"].select { File.file?(_1) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { File.basename(_1) }

  spec.rdoc_options = ["--main", "README.md"]
  spec.extra_rdoc_files = ["README.md", "doc/vector_space.svg"]
end
