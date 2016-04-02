require "digest"

module CarthageCache

  class CartfileResolvedFile

    attr_reader :file_path
    attr_reader :terminal
    attr_reader :swift_version_resolver

    def initialize(file_path, terminal, swift_version_resolver = SwiftVersionResolver.new)
      @file_path = file_path
      @swift_version_resolver = swift_version_resolver
      @terminal = terminal
    end

    def digest
      @digest ||= generate_digest
    end

    def content
      @content ||= File.read(file_path)
    end

    def swift_version
      @swift_version ||= swift_version_resolver.swift_version
    end

    private

      def generate_digest
        terminal.vputs "Generating carthage_cache archive digest using swift version '#{swift_version}' and " \
                      "the content of '#{file_path}'"
        generated_digest = Digest::SHA256.hexdigest(content + "#{swift_version}")
        terminal.vputs "Generated digest: #{generated_digest}"
        generated_digest
      end

  end

end
