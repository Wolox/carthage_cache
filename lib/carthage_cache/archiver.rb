module CarthageCache

  class Archiver

    attr_reader :executor

    def initialize(executor = ShellCommandExecutor.new)
      @executor = executor
    end

    def archive(archive_path, destination_path, &filter_block)
      files = Dir.entries(archive_path).select { |x| !x.start_with?(".") }
      files = files.select(&filter_block) if filter_block
      files = files.sort_by(&:downcase)
      executor.execute("cd #{archive_path} && zip -r -X -y #{File.expand_path(destination_path)} #{files.join(' ')} > /dev/null")
    end

    def unarchive(archive_path, destination_path)
      executor.execute("unzip -o #{archive_path} -d #{destination_path} > /dev/null")
    end

  end

end
