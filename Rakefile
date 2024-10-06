# frozen_string_literal: true

require "English"
require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"
RuboCop::RakeTask.new

begin
  require "bump/tasks"
  Bump.changelog = true
  Bump.tag_by_default = true
rescue LoadError
  # skip loading bump (only available in development)
end

desc "Validate signatures with RBS"
task :rbs do
  puts "Checking signatures with RBS..."
  if system "rbs", "-rbigdecimal", "-Isig", "validate"
    puts "Signatures are good!"
    puts
  else
    exit $CHILD_STATUS.exitstatus || 1
  end
end

desc "Validate code typing with Steep"
task steep: :rbs do
  exit $CHILD_STATUS.exitstatus || 1 unless system "steep", "check"
end

task default: %i[spec rubocop rbs]
