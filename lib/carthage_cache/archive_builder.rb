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

    def build
      archive_path = archive
      upload_archive(archive_path)
      # TODO check if some old archives can be deleted
      # I would store the last N archives and then delete
      # the rest
    end

    private

      def archive
        # TODO Check() that only dependencies that appear
        # in Cartfile.resolved file are going to be archived.
        # This will avoid saving unused dependencies into
        # the archive.
        archive_path = File.join(project.tmpdir, project.archive_filename)
        terminal.puts "Archiving Carthage build directory."
        archiver.archive(project.carthage_build_directory, archive_path)
        archive_path
      end

      def upload_archive(archive_path)
        terminal.puts "Uploading archive with key '#{project.archive_key}'."
        repository.upload(project.archive_filename, archive_path)
      end

  end

end
