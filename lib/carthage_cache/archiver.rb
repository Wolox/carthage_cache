module CarthageCache

  class Archiver

    attr_reader :executor

    def initialize(executor = ShellCommandExecutor.new)
      @executor = executor
    end

    def archive(archive_path, destination_path, &filter_block)
      files = Dir.entries(archive_path).select { |file| !hidden_file?(file) || version_file?(file) }
      files = files.select(&filter_block) if filter_block
      files = files.sort_by(&:downcase)
      executor.execute("cd #{archive_path} && zip -r -X #{File.expand_path(destination_path)} #{files.join(' ')} > /dev/null")
    end

    def unarchive(archive_path, destination_path)
      executor.execute("unzip -o #{archive_path} -d #{destination_path} > /dev/null")
    end

    private

      def hidden_file?(file)
        file.start_with?(".")
      end

      def version_file?(file)
        file.end_with?(".version")
      end

  end

end
