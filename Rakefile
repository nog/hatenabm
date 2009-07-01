$:.unshift('lib')
require 'rubygems'
require 'meta_project'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'rake/contrib/xforge'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'

PKG_NAME = "hatenabm"
# Versioning scheme: MAJOR.MINOR.PATCH
# MAJOR bumps when API is broken backwards
# MINOR bumps when the API is broken backwards in a very slight/subtle (but not fatal) way
# -OR when a new release is made and propaganda is sent out.
# PATCH is bumped for every API addition and/or bugfix (ideally for every commit)
# Later DamageControl can bump PATCH automatically.
#
# (This is subject to change - AH)
#
# REMEMBER TO KEEP PKG_VERSION IN SYNC WITH CHANGELOG
PKG_VERSION = "0.1.2"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*.rb', 
  'test/**/*.rb', 
  'examples/**/*.rb', 
  'doc/**/*'
]

task :default => [:test]

#Rake::TestTask.new(:test) do |t|
#  t.libs << "test"
#  t.test_files = FileList['**/test*.rb']
#  t.verbose = true
#end

# Create a task to build the RDOC documentation tree.
rd = Rake::RDocTask.new("rdoc") do |rdoc|
  rdoc.rdoc_dir = 'html'
  rdoc.title    = "hatenabm"
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include('README', 'CHANGES')
  rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
  rdoc.rdoc_files.exclude('doc/**/*_attrs.rdoc')
end

# ====================================================================
# Create a task that will package the Rake software into distributable
# tar, zip and gem files.

spec = Gem::Specification.new do |s|

  #### Basic information.

  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = "Hatena Bookmark AtomAPI Binding for Ruby"
  s.description = <<-EOF
Hatena Bookmark is a social bookmark service in Japan. (http://b.hatena.ne.jp)

GET/POST/EDIT/DELETE Bookmark via this script.
  EOF

  s.files = PKG_FILES.to_a
  s.require_path = 'lib'

  #### Documentation and testing.

  s.has_rdoc = true
  s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
  s.rdoc_options <<
    '--title' <<  'hatenabm' <<
    '--main' << 'README' <<
    '--line-numbers'
  
  s.test_files = Dir.glob('test/test_*.rb')

  #### Make executable
  s.require_path = 'lib'
  #s.autorequire = 'spec'

  #### Author and project details.

  s.author = "drawnboy" 
  s.email = "drawn.boy@gmail.com"
  s.homepage = "http://hatenabm.rubyforge.org"
  s.rubyforge_project = "hatenabm"
end

desc "Build Gem"
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
task :gem => [:test]

# Support Tasks ------------------------------------------------------

def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
        count += 1
        if line =~ pattern
          puts "#{fn}:#{count}:#{line}"
        end
      end
    end
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /#.*(FIXME|TODO|TBD)/
end

task :release => [:verify_env_vars, :release_files, :publish_doc, :publish_news]

task :verify_env_vars do
  raise "RUBYFORGE_USER environment variable not set!" unless ENV['RUBYFORGE_USER']
  raise "RUBYFORGE_PASSWORD environment variable not set!" unless ENV['RUBYFORGE_PASSWORD']
end

task :publish_doc => [:rdoc] do
  publisher = Rake::RubyForgePublisher.new(PKG_NAME, ENV['RUBYFORGE_USER'])
  publisher.upload
end

desc "Release gem to RubyForge. MAKE SURE PKG_VERSION is aligned with the CHANGELOG file"
task :release_files => [:gem] do
  release_files = FileList[
    "pkg/#{PKG_FILE_NAME}.gem"
  ]

  Rake::XForge::Release.new(MetaProject::Project::XForge::RubyForge.new(PKG_NAME)) do |xf|
    # Never hardcode user name and password in the Rakefile!
    xf.user_name = ENV['RUBYFORGE_USER']
    xf.password = ENV['RUBYFORGE_PASSWORD']
    xf.files = release_files.to_a
    xf.release_name = "HatenaBM #{PKG_VERSION}"
  end
end

desc "Publish news on RubyForge"
task :publish_news => [:gem] do
  release_files = FileList[
    "pkg/#{PKG_FILE_NAME}.gem"
  ]

  Rake::XForge::NewsPublisher.new(MetaProject::Project::XForge::RubyForge.new(PKG_NAME)) do |news|
    # Never hardcode user name and password in the Rakefile!
    news.user_name = ENV['RUBYFORGE_USER']
    news.password = ENV['RUBYFORGE_PASSWORD']
  end
end
