require "foy_runner/version"

require "foy_runner/git_fetcher"
require "foy_api_client"

module Foy
  module Runner
    class Base
      def self.collect_project_packages
        projects = Foy::API::Client::Base.get_projects
        projects.each do |project|
          git_fetcher = Foy::Runner::GitFetcher.new(project.repository)
          begin
            file = git_fetcher.get("Gemfile.lock")
            packages = Foy::RubyHandler.parse(file)
            Foy::API::Client::Base.put_project_packages(system: 'rubygems', project_id: project.id, packages: packages)
          #rescue
            #TODO error handling
          ensure
            git_fetcher.clean_up
          end
        end
      end
    end
  end
end
