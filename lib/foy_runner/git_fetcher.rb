module Foy
  module Runner
    class GitFetcher
      def initialize(url)
        @url = url
      end

      def get(file)
        @dir = Dir.mktmpdir
        `git clone -n #{@url} #{@dir} --depth 1`
        `cd #{@dir}; git checkout HEAD #{file}`
        File.join(@dir, file)
      end

      def get
        @dir = Dir.mktmpdir
        `git clone -n #{@url} #{@dir} --depth 1`
        `cd #{@dir}; git checkout HEAD .`
        @dir
      end

      def clean_up
        FileUtils.remove_entry_secure(@dir, true) if @dir
      end
    end
  end
end
