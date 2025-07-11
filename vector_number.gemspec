# frozen_string_literal: true

require_relative "lib/vector_number/version"

Gem::Specification.new do |spec|
  spec.name = "vector_number"
  spec.version = VectorNumber::VERSION
  spec.authors = ["Alexandr Bulancov"]

  spec.summary = "A library to add together anything."
  spec.homepage = "https://github.com/trinistr/vector_number"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/vector_number/#{VectorNumber::VERSION}"
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{VectorNumber::VERSION}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/v#{VectorNumber::VERSION}/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{lib,sig,exe}/**/*"].select { File.file?(_1) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.rdoc_options << "--main" << "README.md" << "--files" << "CHANGELOG.md,LICENSE.txt"
end
