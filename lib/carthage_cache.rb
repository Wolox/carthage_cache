require "carthage_cache/version"
require "carthage_cache/description"
require "carthage_cache/archive_builder"
require "carthage_cache/archive_installer"
require "carthage_cache/archiver"
require "carthage_cache/carthage_resolved_file"
require "carthage_cache/project"
require "carthage_cache/repository"
require "carthage_cache/terminal"
require "carthage_cache/configuration"
require "carthage_cache/configurator"
require "carthage_cache/configurator_wizard"

module CarthageCache

  class Application

    CACHE_DIR_NAME = "carthage_cache"

    attr_reader :terminal
    attr_reader :archiver
    attr_reader :repository
    attr_reader :project
    attr_reader :config

    def initialize(project_path, verbose, config)
      @terminal = Terminal.new(verbose)
      @archiver = Archiver.new
      @config = Configurator.new(project_path, config).config
      @repository = Repository.new(@config.bucket_name, @config.hash_object[:aws_s3_client_options])
      @project = Project.new(project_path, CACHE_DIR_NAME, terminal)
    end

    def archive_exist?
      repository.archive_exist?(project.archive_filename)
    end

    def install_archive
      if archive_exist?
        archive_installer.install
      else
        terminal.puts "There is no cached archive for the current Cartfile.resolved file."
        exit 1
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
