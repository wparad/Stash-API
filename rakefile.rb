#!/usr/bin/ruby -e
require 'bundler/setup'
require 'fileutils'
require 'rake'
require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'tmpdir'
require 'travis-build-tools'

#Environment variables: http://docs.travis-ci.com/user/environment-variables/
PWD = File.dirname(__FILE__)
PKG_DIR = File.join(PWD, 'pkg')
NAME = 'stash-api'
#### TASKS ####
  RSpec::Core::RakeTask.new(:spec)

  task :default => [:spec]

  desc "Install new version of #{NAME} locally"
  task :redeploy => [:uninstall, :repackage, :deploy]

  task :after_build => [:publish_git_tag, :display_repository]

Gem::PackageTask.new(Gem::Specification.load(Dir['*.gemspec'].first)) do |pkg|
end

publish_git_tag :publish_git_tag do |t, args|
  t.git_repository = %x[git config --get remote.origin.url].split('://')[1]
  t.tag_name = TravisBuildTools::Build::VERSION.to_s
  t.service_user = ENV['GIT_TAG_PUSHER']
end

task :display_repository do
  puts Dir.glob(File.join(PWD, '**', '*'), File::FNM_DOTMATCH).select{|f| !f.match(/\/(\.git|vendor|bundle)\//)}
end

task :set_owner do
  system("gem owner #{NAME} -a wparad@gmail.com")
end

task :uninstall do
  Bundler.with_clean_env do
    puts %x[gem uninstall -x #{NAME} -a]
  end
end

task :deploy do
  Bundler.with_clean_env do
    #Create local gem repository for testing
    Dir.chdir(PKG_DIR) do
      FileUtils.rm_rf('gems')
      gem = Dir["*.gem"].first
      FileUtils.mkdir_p('gems')
      FileUtils.cp(gem, 'gems')
      %x[gem generate_index]
    end
    puts %x[gem install pkg/*.gem --no-ri --no-rdoc -u -N]
  end
end
