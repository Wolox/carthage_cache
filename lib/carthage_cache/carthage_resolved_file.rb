require "digest"

module CarthageCache

  class CartfileResolvedFile

    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
    end

    def digest
      @digest ||= Digest::SHA256.hexdigest(content)
    end

    def content
      @content ||= File.read(file_path)
    end

  end

end
