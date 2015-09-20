# encoding: UTF-8

require 'rubocop/rake_task'
require 'bundler/gem_tasks'

task default: [:rubocop, :build]

desc 'Run rubocop'
RuboCop::RakeTask.new

desc 'Clean generated files'
task :clean do
  puts 'Removing pkg output directory...'
  FileUtils.rm_rf 'pkg'
  puts 'Done.'
end

desc 'List all Rake tasks'
task :list do
  puts "Tasks:\n  #{(Rake::Task.tasks - [Rake::Task[:list]]).join("\n  ")}"
  puts "(type rake -T for exposed tasks and their usage)\n\n"
end
