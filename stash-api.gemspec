#require 'rake'
#require 'travis-build-tools'

Gem::Specification.new() do |s|
  s.name = 'stash-api'
  s.version = '0.0.0.0' #TravisBuildTools::Build::VERSION.to_s
  s.platform = Gem::Platform::RUBY
  s.authors = ['Warren Parad']
  s.license = 'BSD-3-Clause'
  s.email = ["wparad@gmail.com"]
  s.homepage = 'https://github.com/wparad/Stash-API'
  s.summary = 'A lightweight build and deployment tool wrapper'
  s.description = "Stash API is a ruby library to interact with stash rest API."
  s.files = Dir.glob("{bin,lib}/{**}/{*}", File::FNM_DOTMATCH).select{|f| !(File.basename(f)).match(/^\.+$/)}
  #s.executables = [EXECUTABLE_NAME]
  #s.requirements << 'none'
  s.require_paths = ['lib']
  s.add_runtime_dependency('bundler', '~> 1.10')
  s.add_runtime_dependency('rest-client', '~>1.8')
  s.add_runtime_dependency('rubyzip', '~> 1.1')
end
