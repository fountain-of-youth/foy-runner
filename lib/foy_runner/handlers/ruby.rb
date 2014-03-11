module Foy::Runner
  module Handlers
    module Ruby
      class Parse
        def initialize(directory)
          @directory = directory
          @gemfile_lock = File.join(@directory, 'Gemfile.lock')
        end

        def execute
          if File.exist?(@gemfile_lock)
            parse_gemfile_lock
          end
        end

        def parse_gemfile_lock
          lockfile = Bundler::LockfileParser.new(File.open(@gemfile_lock, 'r').read)
          dependencies = lockfile.dependencies.collect(&:name)
          lockfile.specs.collect do |spec|
            {name: spec.name, version: spec.version.to_s} if dependencies.include?(spec.name)
          end.compact
        end
      end

      class Package
        def self.latest_version_for(gem)
          Gem.latest_version_for(gem).version rescue nil
        end
      end
    end
  end
end
