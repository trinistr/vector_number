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
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files =
    IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
      ls.each_line("\x0", chomp: true).select { |f| f.start_with?(*%w[ext/ lib/ sig/]) }
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md"]
  spec.rdoc_options << "--main" << "README.md"
end
