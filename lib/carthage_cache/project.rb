module CarthageCache

  class Project

    attr_reader :cartfile
    attr_reader :project_path
    attr_reader :archive_base_path
    attr_reader :cache_dir_name
    attr_reader :terminal
    attr_reader :tmpdir_base_path

    def initialize(project_path, cache_dir_name, archive_base_path, terminal, tmpdir, swift_version_resolver = SwiftVersionResolver.new)
      @project_path = project_path
      @cache_dir_name = cache_dir_name
      @archive_base_path = archive_base_path
      @terminal = terminal
      @tmpdir_base_path = tmpdir
      @cartfile = CartfileResolvedFile.new(cartfile_resolved_path, terminal, swift_version_resolver)
    end

    def archive_filename
      @archive_filename ||= "#{archive_key}.zip"
    end

    def archive_path
      if @archive_base_path.nil?
        @archive_path ||= archive_filename
      else 
        @archive_path ||= File.join(archive_base_path, archive_filename)
      end
    end

    def tmp_archive_path
      @tmp_archive_path = File.join(tmpdir, archive_filename)
    end

    def archive_key
      cartfile.digest
    end

    def tmpdir
      @tmpdir ||= create_tmpdir
    end

    def carthage_build_directory
      @carthage_build_directory ||= File.join(project_path, "Carthage", "Build")
    end

    def all_frameworks
      cartfile.frameworks
    end

    private

      def cartfile_resolved_path
        @carfile_resolved_path ||= File.join(project_path, "Cartfile.resolved")
      end

      def create_tmpdir
        dir = File.join(tmpdir_base_path, cache_dir_name)
        unless File.exist?(dir)
          terminal.vputs "Creating carthage cache directory at '#{dir}'."
          FileUtils.mkdir_p(dir)
        end
        dir
      end

  end

end
