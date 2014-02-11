require 'spec_helper'

describe Foy::Runner::Base do
  subject do
    Foy::Runner::Base.new(client)
  end

  let(:client) do
    double(:client)
  end

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
      client.stub(:get_projects).and_return(projects)
      client.stub(:put_project_packages)
      Foy::Runner::GitFetcher.stub(:new).and_return(fetcher)
      Foy::RubyHandler.stub(:parse)
    end

    context "successful collecting" do
      it "parses Gemfile.lock for each project" do
        fetcher.should_receive(:get).with("Gemfile.lock").twice
        subject.collect_project_packages
      end

      it "sends packages to foy-api for each project" do
        Foy::RubyHandler.stub(:parse).
          and_return(packages1, packages2)

        client.should_receive(:put_project_packages).
          with(system: 'rubygems', project_id: '1', packages: packages1).
          ordered

        client.should_receive(:put_project_packages).
          with(system: 'rubygems', project_id: '2', packages: packages2).
          ordered

        subject.collect_project_packages
      end

      it "cleans the git fetcher" do
        fetcher.should_receive(:clean_up).twice
        subject.collect_project_packages
      end
    end
  end

  describe ".update_packages" do
    let(:packages) do
      [OpenStruct.new(name: 'rspec', version: '1.0.0')]
    end

    before do
      client.stub(:get_packages).and_return(packages)
      client.stub(:put_packages)
      Foy::RubyHandler.stub(:latest_version_for).and_return('2.0.0')
    end

    it "uses RubyHandler to get the last version" do
      Foy::RubyHandler.should_receive(:latest_version_for).once
      subject.update_packages
    end

    it "sends updated packages" do
      client.should_receive(:put_packages).
        with(system: 'rubygems', packages: [{name: 'rspec', version: '2.0.0'}])
      subject.update_packages
    end
  end
end
