require 'spec_helper'

describe Foy::Runner::Base do
  describe ".collect_project_packages" do
    let(:projects) do
      [
        OpenStruct.new(id: '1', repository: 'https://repo/example1.git'),
        OpenStruct.new(id: '2', repository: 'https://repo/example2.git')
      ]
    end

    let(:packages1) do
      double(:packages1)
    end

    let(:packages2) do
      double(:packages2)
    end

    let(:file) do
      double(:file)
    end

    let(:fetcher) do
      double(:fetcher, get: file, clean_up: nil)
    end

    before do
      Foy::API::Client::Base.stub(:get_projects).and_return(projects)
      Foy::API::Client::Base.stub(:put_project_packages)
      Foy::Runner::GitFetcher.stub(:new).and_return(fetcher)
      Foy::RubyHandler.stub(:parse)
    end

    context "successful collecting" do
      it "parses Gemfile.lock for each project" do
        fetcher.should_receive(:get).with("Gemfile.lock").twice
        Foy::Runner::Base.collect_project_packages
      end

      it "sends packages to foy-api for each project" do
        Foy::RubyHandler.stub(:parse).
          and_return(packages1, packages2)

        Foy::API::Client::Base.should_receive(:put_project_packages).
          with(system: 'rubygems', project_id: '1', packages: packages1).
          ordered

        Foy::API::Client::Base.should_receive(:put_project_packages).
          with(system: 'rubygems', project_id: '2', packages: packages2).
          ordered

        Foy::Runner::Base.collect_project_packages
      end

      it "cleans the git fetcher" do
        fetcher.should_receive(:clean_up).twice
        Foy::Runner::Base.collect_project_packages
      end
    end
  end

  describe ".update_packages" do
    let(:packages) do
      [OpenStruct.new(name: 'rspec', version: '1.0.0')]
    end

    before do
      Foy::API::Client::Base.stub(:get_packages).and_return(packages)
      Foy::API::Client::Base.stub(:put_packages)
      Foy::RubyHandler.stub(:latest_version_for).and_return('2.0.0')
    end

    it "uses RubyHandler to get the last version" do
      Foy::RubyHandler.should_receive(:latest_version_for).once
      Foy::Runner::Base.update_packages
    end

    it "sends updated packages" do
      Foy::API::Client::Base.should_receive(:put_packages).
        with(system: 'rubygems', packages: [{name: 'rspec', version: '2.0.0'}])
      Foy::Runner::Base.update_packages
    end
  end
end
