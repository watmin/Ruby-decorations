# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'

def empty_directory(directory)
  FileUtils.remove_entry(directory)
  FileUtils.mkdir(directory)
end

# clean up the workspace
task(:clean) do
  empty_directory('doc')
  empty_directory('out')
  empty_directory('pkg')
end

# unit tests
RSpec::Core::RakeTask.new(:spec) do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.rspec_opts = '--require spec_helper ' \
                    '--format documentation ' \
                    '--format html ' \
                    '--out out/rspec_unit.html'
end
task(default: :spec)

# configure rubocop
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = [
    '--format', 'simple',
    '--format', 'html',
    '--out', 'out/rubocop.html',
    'lib/**/*.rb',
    'spec/**/*.rb'
  ]
end
task(default: :rubocop)

# configure yard
YARD::Rake::YardocTask.new(:yard) do |task|
  task.files = Dir['lib/**/*.rb']
  task.options = [
    '--quiet' # YARD doesn't like the methods that received (**args)
  ]
  task.stats_options = [
    '--list-undoc'
  ]
end
task(default: :yard)

# documentation coverage
Yardstick::Rake::Measurement.new(:yardstick_measure) do |task|
  task.output = 'out/yard-report.txt'
end
task(default: :yardstick_measure)

# documentation enforcement
Yardstick::Rake::Verify.new(:yardstick_verify) do |task|
  task.threshold = 100
end
task(default: :yardstick_verify)

# Require tests, syntax and documentation to pass before building
task(build: %i[spec rubocop yard yardstick_measure yardstick_verify])

# Require a succesful build before release
task(release: %i[build])
