require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

# target that generates junit test report for CI builds
RSpec::Core::RakeTask.new(:ci_spec) do |t|
  t.fail_on_error = false
  t.rspec_opts = "--no-drb -r rspec_junit_formatter --format RspecJunitFormatter -o junit.xml"
end

task :default => :spec 
