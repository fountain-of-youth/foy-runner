require 'spec_helper'

describe Foy::Runner::GitFetcher do
  let(:url) { "git://github.com/fountain-of-youth/foy-web.git" }
  let(:fetcher) { Foy::Runner::GitFetcher.new(url) }

  describe "#get" do
    it "uses a tmp dir" do
      Dir.should_receive(:mktmpdir).and_call_original
      fetcher.get("Gemfile.lock")
    end
  end

  describe "#clean_up" do
    context "called after temp dir has been created" do
      before do
        fetcher.get("any")
      end

      it "removes folder securely" do
        FileUtils.should_receive(:remove_entry_secure).with(an_instance_of(String), true)
        fetcher.clean_up
      end
    end

    context "called before temp dir has been created" do
      it "does nothing" do
        FileUtils.should_not_receive(:remove_entry_secure)
        fetcher.clean_up
      end
    end
  end
end
