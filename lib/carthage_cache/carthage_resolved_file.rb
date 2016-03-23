require "digest"

module CarthageCache

  class CartfileResolvedFile

    attr_reader :file_path

    def initialize(file_path, swift_version_resolver = SwiftVersionResolver.new)
      @file_path = file_path
      @swift_version_resolver = swift_version_resolver
    end

    def digest
      @digest ||= Digest::SHA256.hexdigest(content + "#{swift_version}")
    end

    def content
      @content ||= File.read(file_path)
    end

    def swift_version
      @swift_version ||= @swift_version_resolver.swift_version
    end

  end

end
