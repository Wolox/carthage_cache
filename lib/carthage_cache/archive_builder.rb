module CarthageCache

  class ArchiveBuilder

    attr_reader :terminal
    attr_reader :repository
    attr_reader :archiver
    attr_reader :project

    def initialize(terminal, repository, archiver, project)
      @terminal = terminal
      @repository = repository
      @archiver = archiver
      @project = project
    end

    def build(platforms = nil)
      archive_path = archive(platforms)
      upload_archive(archive_path)
      # TODO check if some old archives can be deleted
      # I would store the last N archives and then delete
      # the rest
    end

    private

      def archive(platforms = nil)
        archive_path = File.join(project.tmpdir, project.archive_filename)
        if platforms
          terminal.puts "Archiving Carthage build directory for #{platforms.join(',')} platforms."
        else
          terminal.puts "Archiving Carthage build directory for all platforms."
        end

        filter_block = nil
        if platforms
          filter_block = ->(file) do
            lock_file?(file) || platforms.map(&:downcase).include?(file.downcase)
          end
        end

        archiver.archive(project.carthage_build_directory, archive_path, &filter_block)
        archive_path
      end

      def upload_archive(archive_path)
        terminal.puts "Uploading archive with key '#{project.archive_key}'."
        repository.upload(project.archive_path, archive_path)
      end

      def lock_file?(file)
        file == CarthageCacheLock::LOCK_FILE_NAME
      end

  end

end
