require 'fileutils'

module CarthageCache

  class BuildCollector

    attr_reader :terminal
    attr_reader :build_directory
    attr_reader :required_frameworks
    attr_reader :command_executor

    def initialize(terminal, build_directory, required_frameworks, command_executor = ShellCommandExecutor.new)
      @terminal = terminal
      @build_directory = build_directory
      @required_frameworks = Set.new(required_frameworks)
      @command_executor = command_executor
    end

    def delete_unused_frameworks(white_list = {})
      terminal.vputs "Deleting unused frameworks from '#{build_directory}' ..."
      list_built_frameworks.each do |framework_path|
        if delete_framework?(framework_path, white_list)
          delete_framework_files(framework_path)
        end
      end
    end

    private

      def delete_framework?(framework_path, white_list)
        framework = framework_name(framework_path)
        if required_frameworks.include?(white_list[framework])
          false
        else
          ! required_frameworks.include?(framework)
        end
      end

      def list_built_frameworks
        Dir[File.join(build_directory, "/**/*.framework")]
      end

      def framework_name(framework_path)
        Pathname.new(framework_path).basename(".framework").to_s
      end

      def delete_framework_files(framework_path)
        framework_dsym_path = "#{framework_path}.dSYM"
        terminal.vputs "Deleting #{framework_name(framework_path)} files because they are no longer needed ..."
        terminal.vputs "Deleting '#{framework_dsym_path}' ..."
        FileUtils.rm_r(framework_dsym_path)
        terminal.vputs "Deleting '#{framework_path}' ..."
        FileUtils.rm_r(framework_path)
        symbol_map_files(framework_dsym_path).each do |symbol_table_file|
          terminal.vputs "Deleting '#{symbol_table_file}' ..."
          FileUtils.rm(symbol_table_file)
        end
        terminal.vputs ""
      end

      def symbol_map_files(framework_dsym_path)
        uuid_dwarfdump(framework_dsym_path)
          .split("\n")
          .map { |line| line.match(/UUID: (.*) \(/)[1] }
          .map { |uuid| File.expand_path(File.join(framework_dsym_path, "../#{uuid}.bcsymbolmap")) }
      end

      def uuid_dwarfdump(framework_dsym_path)
        command_executor.execute("/usr/bin/xcrun dwarfdump --uuid #{framework_dsym_path}")
      end

  end

end
