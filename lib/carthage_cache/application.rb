require 'yaml'

module CarthageCache

  class Application

    CACHE_DIR_NAME = "carthage_cache"

    attr_reader :terminal
    attr_reader :archiver
    attr_reader :repository
    attr_reader :project
    attr_reader :config

    def initialize(project_path, verbose, config, repository: AWSRepository, terminal: Terminal, swift_version_resolver: SwiftVersionResolver)
      @terminal = terminal.new(verbose)
      @archiver = Archiver.new
      @config = Configurator.new(@terminal, project_path, config).config
      if @config.local_only?
          cacheDirectory = File.new(@config.local_mode)
          @repository = LocalRepository.new(cacheDirectory)
      else
        clazz = @config.read_only? ? HTTPRepository : repository
        @repository = clazz.new(@config.bucket_name, @config.hash_object[:aws_s3_client_options])
      end  
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

    def create_archive(force = false, prune = false, prune_white_list = nil)
      if force || !archive_exist?
        prune_build_directory(prune_white_list) if prune
        archive_builder.build
      end
    end

    def prune_build_directory(white_list)
      if white_list && File.exist?(white_list)
        terminal.vputs "Prunning build directory with white list '#{white_list}' ..."
        white_list = YAML.load(File.read(white_list))
      else
        white_list = {}
        terminal.vputs "Prunning build directory ..."
      end
      build_collector.delete_unused_frameworks(white_list)
    end

    private

      def archive_installer
        @archive_installer ||= ArchiveInstaller.new(terminal, repository, archiver, project)
      end

      def archive_builder
        @archive_builder ||= ArchiveBuilder.new(terminal, repository, archiver, project)
      end

      def build_collector
        @build_collector ||= BuildCollector.new(terminal, project.carthage_build_directory, project.all_frameworks)
      end

  end

end
