# I think this is the one that should be moved to the extension Rakefile template

# In rails 1.2, plugins aren't available in the path until they're loaded.
# Check to see if the rspec plugin is installed first and require
# it if it is.  If not, use the gem version.

# Determine where the RSpec plugin is by loading the boot
unless defined? RADIANT_ROOT
  ENV["RAILS_ENV"] = "test"
  case
  when ENV["RADIANT_ENV_FILE"]
    require File.dirname(ENV["RADIANT_ENV_FILE"]) + "/boot"
  when File.dirname(__FILE__) =~ %r{vendor/radiant/vendor/extensions}
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../../")}/config/boot"
  else
    require "#{File.expand_path(File.dirname(__FILE__) + "/../../../")}/config/boot"
  end
end

require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'active_support'

rspec_base = File.expand_path(RADIANT_ROOT + '/vendor/plugins/rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)
require 'spec/rake/spectask'
# require 'spec/translator'

$:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
require 'cucumber/rake/task'

# Cleanup the RADIANT_ROOT constant so specs will load the environment
Object.send(:remove_const, :RADIANT_ROOT)

extension_root = File.expand_path(File.dirname(__FILE__))

task :default => :spec
task :stats => "spec:statsetup"

desc "Run all specs in spec directory"
task :spec do
  errors = %w(spec:integration spec:models spec:controllers spec:views spec:helpers).collect do |task|
    begin
      puts %{\nRunning #{task.gsub('spec:', '').titlecase} Spec Task}
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    # ensure
    #   if task == 'spec:integration'
    #     Rake::Task["db:test:load"].reenable
    #     Rake::Task["db:schema:load"].reenable
    #     Rake::Task["db:test:prepare"].execute
    #   end
    end
  end.compact
  abort "Errors running #{errors.to_sentence}!" if errors.any?
end


namespace :spec do
  desc "Run all specs in spec directory with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{extension_root}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec', '--rails']
  end
  
  desc "Print Specdoc for all specs"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  [:models, :controllers, :views, :helpers].each do |sub|
    desc "Run the specs under spec/#{sub}"
    Spec::Rake::SpecTask.new(sub) do |t|
      t.spec_opts = ['--options', "\"#{extension_root}/spec/spec.opts\""]
      t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
    end
  end

  Cucumber::Rake::Task.new(:integration) do |t|
    t.cucumber_opts = "--format progress"
  end

  # Setup specs for stats
  task :statsetup do
    require 'code_statistics'
    ::STATS_DIRECTORIES << %w(Model\ specs spec/models)
    ::STATS_DIRECTORIES << %w(View\ specs spec/views)
    ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers)
    ::STATS_DIRECTORIES << %w(Helper\ specs spec/views)
    ::CodeStatistics::TEST_TYPES << "Model specs"
    ::CodeStatistics::TEST_TYPES << "View specs"
    ::CodeStatistics::TEST_TYPES << "Controller specs"
    ::CodeStatistics::TEST_TYPES << "Helper specs"
    ::STATS_DIRECTORIES.delete_if {|a| a[0] =~ /test/}
  end

  namespace :db do
    namespace :fixtures do
      desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
      task :load => :environment do
        require 'active_record/fixtures'
        ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
        (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'spec', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
          Fixtures.create_fixtures('spec/fixtures', File.basename(fixture_file, '.*'))
        end
      end
    end
  end
end

desc 'Generate documentation for the chronicle extension.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ChronicleExtension'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Load any custom rakefiles for extension
Dir[File.dirname(__FILE__) + '/tasks/*.rake'].sort.each { |f| require f }