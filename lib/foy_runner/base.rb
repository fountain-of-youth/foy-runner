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
            dir = git_fetcher.get
            packages = Foy::Runner::Handlers::Ruby::Parse.new(dir).execute
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
            version: Foy::Runner::Handlers::Ruby::Package.latest_version_for(package.name)
          }
        end

        @client.put_packages(system: 'rubygems', packages: updated_packages)
      end
    end
  end
end
