require 'spec_helper'

describe Foy::Runner::Handlers::Ruby do
  describe "Parse" do
    subject do
      Foy::Runner::Handlers::Ruby::Parse.new("spec/fixtures/")
    end

    let(:parse!) {subject.execute} 

    it "uses bundler parser" do
      Bundler::LockfileParser.should_receive(:new)
        .with(File.open("spec/fixtures/Gemfile.lock", 'r').read)
        .and_call_original
      parse!
    end

    it "returns current dependencies (name and version)" do
      expect(parse!).to be == [{name: 'rake', version: '10.0.3'}, {name: 'rspec', version: '2.13.0'}]
    end
  end

  describe "Package" do
    subject do
      Foy::Runner::Handlers::Ruby::Package
    end
    let(:version) { double(:version, version: "2.0.1") }

    it "uses rubygem" do
      Gem.should_receive(:latest_version_for).with("package").and_return(version)
      subject.latest_version_for("package")
    end

    it "returns version as string" do
      Gem.stub(:latest_version_for).with("package").and_return(version)
      expect(subject.latest_version_for("package")).to be_eql("2.0.1")
    end

    it "returns nil if commands raises error" do
      Gem.stub(:latest_version_for).and_raise("error")
      expect(subject.latest_version_for("package")).to be_nil
    end
  end
end
