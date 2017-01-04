
module CarthageCache

  class CarthageCacheLock

    LOCK_FILE_NAME = "CarthageCache.lock"

    attr_reader :lock_file_path

    def initialize(build_directory)
      @lock_file_path = File.join(build_directory, LOCK_FILE_NAME)
    end

    def lock_digest
      File.read(lock_file_path).strip if File.exist?(lock_file_path)
    end

    def write_lock_digest(digest)
      File.open(lock_file_path, "w") { |f| f.write(digest) }
    end

    def valid_digest?(digest)
      lock_digest == digest
    end

  end

end
