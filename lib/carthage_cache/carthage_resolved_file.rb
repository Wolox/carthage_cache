require "digest"

module CarthageCache

  class CartfileResolvedFile

    attr_reader :file_path

    def initialize(file_path, executor = ShellCommandExecutor.new)
      @file_path = file_path
      @executor = executor
    end

    def digest
      @digest ||= Digest::SHA256.hexdigest(content + "#{swift_version}")
    end

    def content
      @content ||= File.read(file_path)
    end

    def swift_version
      output = @executor.execute('xcrun swift -version').chomp
      version_string = /(\d+\.)?(\d+\.)?(\d+)/.match(output).to_s
      Gem::Version.new(version_string)
    end

  end

end
