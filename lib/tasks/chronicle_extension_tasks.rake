namespace :radiant do
  namespace :extensions do
    namespace :chronicle do
      
      desc "Runs the migration of the Chronicle extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          ChronicleExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          ChronicleExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Chronicle to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from ChronicleExtension"
        Dir[ChronicleExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(ChronicleExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
