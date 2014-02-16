module Foy::Runner
  module Handlers
    module Ruby
      class << self
        def parse(file)
          lockfile = Bundler::LockfileParser.new(File.open(file, 'r').read)
          dependencies = lockfile.dependencies.collect(&:name)
          lockfile.specs.collect do |spec|
            {name: spec.name, version: spec.version.to_s} if dependencies.include?(spec.name)
          end.compact
        end

        def latest_version_for(gem)
          Gem.latest_version_for(gem).version rescue nil
        end
      end
    end
  end
end
