module CarthageCache

  class Project

    attr_reader :cartfile
    attr_reader :project_path
    attr_reader :cache_dir_name
    attr_reader :terminal

    def initialize(project_path, cache_dir_name, terminal)
      @project_path = project_path
      @cache_dir_name = cache_dir_name
      @terminal = terminal
      @cartfile = CartfileResolvedFile.new(cartfile_resolved_path)
    end

    def archive_filename
      @archive_filename ||= "#{archive_key}.zip"
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

    private

      def cartfile_resolved_path
        @carfile_resolved_path ||= File.join(project_path, "Cartfile.resolved")
      end

      def create_tmpdir
        dir = File.join(Dir.tmpdir, cache_dir_name)
        unless File.exist?(dir)
          terminal.vputs "Creating carthage cache directory at '#{dir}'."
          FileUtils.mkdir_p(dir)
        end
        dir
      end

  end

end
