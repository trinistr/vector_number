# frozen_string_literal: true

require "English"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop steep]

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

desc "Validate code typing with steep"
task steep: :rbs do
  exit $CHILD_STATUS.exitstatus || 1 unless system "steep", "check"
end
