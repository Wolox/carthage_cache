module CarthageCache

  class ArchiveInstaller

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

    def install
      archive_path = download_archive
      unarchive(archive_path)
    end

    private

      def create_carthage_build_directory
        unless File.exist?(project.carthage_build_directory)
          terminal.vputs "Creating Carthage build directory '#{project.carthage_build_directory}'."
          FileUtils.mkdir_p(project.carthage_build_directory)
        end
        project.carthage_build_directory
      end

      def download_archive
        archive_path = File.join(project.tmpdir, project.archive_filename)

        if File.exist?(archive_path)
          terminal.puts "Archive with key '#{archive_path}' already downloaded in local cache."
        else
          terminal.puts "Downloading archive with key '#{archive_path}'."
          repository.download(project.archive_path, archive_path)
        end

        archive_path
      end

      def unarchive(archive_path)
        build_directory = create_carthage_build_directory
        terminal.puts "Unarchiving '#{archive_path}' into '#{build_directory}'."
        archiver.unarchive(archive_path, build_directory)
      end

  end

end
