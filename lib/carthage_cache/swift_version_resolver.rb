module CarthageCache

  class SwiftVersionResolver

    def initialize(executor = ShellCommandExecutor.new)
      @executor = executor
    end

    def swift_version
      output = @executor.execute('xcrun swift -version').chomp
      version_string = /(\d+\.)?(\d+\.)?(\d+)/.match(output).to_s
      Gem::Version.new(version_string)
    end

  end

end
