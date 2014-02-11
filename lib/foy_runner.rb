require "foy_runner/version"

require "foy_runner/git_fetcher"
require "foy_api_client"

module Foy
  module Runner
    class Base
      def initialize(client)
        @client = client
      end

      def collect_project_packages
        projects = @client.get_projects
        projects.each do |project|
          git_fetcher = Foy::Runner::GitFetcher.new(project.repository)
          begin
            file = git_fetcher.get("Gemfile.lock")
            packages = Foy::RubyHandler.parse(file)
            @client.put_project_packages(system: 'rubygems', project_id: project.id, packages: packages)
          #rescue
            #TODO error handling
          ensure
            git_fetcher.clean_up
          end
        end
      end

      def update_packages
        packages = @client.get_packages(system: 'rubygems')

        updated_packages = packages.collect do |package|
          {
            name: package.name,
            version: Foy::RubyHandler.latest_version_for(package.name)
          }
        end

        @client.put_packages(system: 'rubygems', packages: updated_packages)
      end
    end
  end
end
