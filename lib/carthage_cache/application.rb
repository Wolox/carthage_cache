module CarthageCache

  class Application

    CACHE_DIR_NAME = "carthage_cache"

    attr_reader :terminal
    attr_reader :archiver
    attr_reader :repository
    attr_reader :project
    attr_reader :config

    def initialize(project_path, verbose, config, repository: Repository, terminal: Terminal, swift_version_resolver: SwiftVersionResolver)
      @terminal = terminal.new(verbose)
      @archiver = Archiver.new
      @config = Configurator.new(@terminal, project_path, config).config
      @repository = repository.new(@config.bucket_name, @config.hash_object[:aws_s3_client_options])
      @project = Project.new(project_path, CACHE_DIR_NAME, @terminal, @config.tmpdir, swift_version_resolver.new)
    end

    def archive_exist?
      repository.archive_exist?(project.archive_filename)
    end

    def install_archive
      if archive_exist?
        archive_installer.install
        true
      else
        terminal.puts "There is no cached archive for the current Cartfile.resolved file."
        false
      end
    end

    def create_archive(force = false)
      archive_builder.build if force || !archive_exist?
    end

    private

      def archive_installer
        @archive_installer ||= ArchiveInstaller.new(terminal, repository, archiver, project)
      end

      def archive_builder
        @archive_builder ||= ArchiveBuilder.new(terminal, repository, archiver, project)
      end

  end

end
